import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

type DbConfig record {
    string host;
    int port;
    string username;
    string password;
    string database;
};

configurable DbConfig dbConfig = ?;

// Create a mysql client to be used for remote function calls.
final mysql:Client dbClient = check new (dbConfig.host, dbConfig.username, dbConfig.password, dbConfig.database, dbConfig.port);

isolated function getUser(string userId) returns UserData|error {
    sql:ParameterizedQuery query = `SELECT * FROM user WHERE id = ${userId}`;
    return dbClient->queryRow(query);
}

isolated function getUsers() returns stream<UserData, error?> {
    sql:ParameterizedQuery query = `SELECT * FROM user`;
    return dbClient->query(query);
}

isolated function createUser(UserData user) returns error? {
    sql:ParameterizedQuery query = `INSERT INTO user (id, name, email) VALUES (${user.id}, ${user.name})`;
    _ = check dbClient->execute(query);
}

isolated function deleteUser(string userId) returns error? {
    sql:ParameterizedQuery query = `DELETE FROM user WHERE id = ${userId}`;
    _ = check dbClient->execute(query);
}

// Get posts by user id.
isolated function getPosts(string? userId) returns stream<PostData, error?> {
    sql:ParameterizedQuery query;
    if userId is string {
        query = `SELECT * FROM post WHERE user_id = ${userId}`;
    } else {
        query = `SELECT * FROM post`;
    }
    return dbClient->query(query);
}

isolated function getPost(string id) returns PostData|error {
    sql:ParameterizedQuery query = `SELECT * FROM post WHERE id = ${id}`;
    return dbClient->queryRow(query);
}

isolated function createPost(PostData post) returns error? {
    sql:ParameterizedQuery query = `INSERT INTO post (id, user_id, title, content) VALUES (${post.id}, ${post.user_id}, ${post.title}, ${post.content})`;
    _ = check dbClient->execute(query);
}

isolated function deletePost(string id) returns error? {
    sql:ParameterizedQuery query = `DELETE FROM post WHERE id = ${id}`;
    _ = check dbClient->execute(query);
}
