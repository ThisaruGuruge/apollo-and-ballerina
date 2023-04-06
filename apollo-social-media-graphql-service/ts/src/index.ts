import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import { ApolloServerPluginDrainHttpServer } from '@apollo/server/plugin/drainHttpServer';
import config from 'config';
import cors from 'cors';
import express from 'express';
import http from 'http';

import { typeDefs } from "./graphql/schema.js";
import { resolvers } from "./graphql/resolvers.js";
import { getHttpContext, UserContext } from './utils.js';

const app = express();
const httpServer = http.createServer(app);
const server = new ApolloServer<UserContext>({
    typeDefs,
    resolvers,
    plugins: [ApolloServerPluginDrainHttpServer({ httpServer })],
});

interface ServerConfig {
    port: number;
}

const { port }: ServerConfig = config.get('server');

await server.start();
app.use(
    "/social-media",
    cors<cors.CorsRequest>(),
    express.json(),
    expressMiddleware(server, {
        context: getHttpContext,
    }),
);

await new Promise<void>((resolve) => httpServer.listen({ port }, resolve));
console.log(`🚀 Server ready at http://localhost:${port}/social-media`);
