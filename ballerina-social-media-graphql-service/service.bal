import ballerina/uuid;
import ballerina/log;
import xlibb/pubsub;
import ballerina/graphql;

configurable record {int port;} serviceConfigs = ?;

@graphql:ServiceConfig {
    contextInit: contextInit,
    cors: {
        allowOrigins: ["*"]
    },
    graphiql: {
        enabled: true
    }
}
service SocialMediaService /social\-media on new graphql:Listener(serviceConfigs.port) {
    private final pubsub:PubSub postPubSub;
    private final string POST_TOPIC = "post";

    isolated function init() returns error? {
        self.postPubSub = new(false);
        check self.postPubSub.createTopic(self.POST_TOPIC);
        log:printInfo(string `💃 Server ready at http://localhost:${serviceConfigs.port}/social-media`);
    }

    # Returns the list of users.
    # + return - List of users
    resource function get users() returns User[]|error {
        stream<UserData, error?> users = getUsers();
        return from UserData userData in users
            select new (userData);
    }

    # Returns the user with the given ID.
    # + id - ID of the user
    # + return - User with the given ID
    resource function get user(string id) returns User|error {
        UserData userData = check getUser(id);
        return new (userData);
    }

    # Returns the list of posts from a user.
    # + id - ID of the user
    # + return - List of posts
    resource function get posts(string? id) returns Post[]|error {
        stream<PostData, error?> posts = getPosts(id);
        return from PostData postData in posts
            select new (postData);
    }

    # Creates a new user.
    # + user - User to be created
    # + return - Created user
    remote function createUser(NewUser user) returns User|error {
        string id = uuid:createType1AsString();
        check createUser(
            {
            id,
            name: user.name,
            age: user.age
        });
        return new ({
            id,
            name: user.name,
            age: user.age
        });
    }

    # Deletes a user. Only the user can delete their own account. Will return an authentication/authorization error if the user cannot be authenticated/authorized.
    # + context - GraphQL context
    # + id - ID of the user
    # + return - Deleted user
    remote function deleteUser(graphql:Context context, string id) returns User|error {
        UserData user = check getUser(id);
        string token = check authenticate(context);
        check authorize(token, id);
        check deleteUser(id);
        return new (user);
    }

    # Creates a new post. Can return authentication error if the user is not authenticated.
    # + context - GraphQL context
    # + newPost - Post to be created
    # + return - Created post
    remote function createPost(graphql:Context context, NewPost newPost) returns Post|error {
        string id = uuid:createType1AsString();
        string user_id = check authenticate(context);
        check createPost({
            id,
            title: newPost.title,
            content: newPost.content,
            user_id
        });
        Post post = new (check getPost(id));
        check self.postPubSub.publish(self.POST_TOPIC, post);
        return post;
    }

    # Deletes a post with the given ID. Can return authentication/authorization errors if the user cannot be authenticated/authorized.
    # + context - GraphQL context
    # + id - ID of the post
    # + return - Deleted post
    remote function deletePost(graphql:Context context, string id) returns Post|error {
        string token = check authenticate(context);
        PostData post = check getPost(id);
        check authorize(token, post.user_id);
        check deletePost(id);
        return new (post);
    }

    # Subscribe to new posts.
    # + return - Stream of new posts
    resource function subscribe newPosts() returns stream<Post, error?>|error {
        return self.postPubSub.subscribe(self.POST_TOPIC, -1);
    }
}
