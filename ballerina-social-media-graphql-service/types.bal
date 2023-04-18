import ballerina/graphql;
import ballerina/io;

type SocialMediaService distinct service object {
    *graphql:Service;

    // Query Type
    resource function get users() returns User[]|error;
    resource function get user(string id) returns User|error;
    resource function get posts(string? id) returns Post[]|error;

    // Mutation Type
    remote function createUser(NewUser user) returns User|error;
    remote function deleteUser(graphql:Context context, string id) returns User|error;
    remote function createPost(graphql:Context context, NewPost newPost) returns Post|error;
    remote function deletePost(graphql:Context context, string id) returns Post|error;
};

type UserData record {
    string id;
    string name;
    int age;
};

type PostData record {
    string id;
    string title;
    string content;
    string user_id; // To match the column name in the database
};

# Represents the User type in the GraphQL schema.
isolated service class User {
    private final readonly & UserData userData;

    isolated function init(UserData userData) {
        self.userData = userData.cloneReadOnly();
    }

    # The `id` of the User
    # + return - The `id` of the User
    isolated resource function get id() returns string => self.userData.id;

    # The `name` of the User
    # + return - The `name` of the User
    isolated resource function get name() returns string => self.userData.name;

    # The `age` of the User
    # + return - The `age` of the User
    isolated resource function get age() returns int => self.userData.age;

    # The `posts` posted by the User
    # + return - The `posts` posted by the User
    isolated resource function get posts() returns Post[]|error {
        stream<PostData, error?> posts = getPosts(self.userData.id);
        return from PostData postData in posts
            select new Post(postData);
    }
}

# Represents the Post type in the GraphQL schema.
isolated service class Post {
    private final readonly & PostData postData;

    isolated function init(PostData postData) {
        self.postData = postData.cloneReadOnly();
    }

    # The `id` of the Post
    # + return - The `id` of the Post
    isolated resource function get id() returns string => self.postData.id;

    # The `title` of the Post
    # + return - The `title` of the Post
    isolated resource function get title() returns string => self.postData.title;

    # The `content` of the Post
    # + return - The `content` of the Post
    isolated resource function get content() returns string => self.postData.content;

    # The `author` of the Post
    # + return - The `User` posted the Post
    isolated resource function get author() returns User|error {
        io:println("[Post Data]: ", self.postData);
        UserData user = check getUser(self.postData.user_id);
        return new User(user);
    }
}

# Represents the NewUser type in the GraphQL schema.
type NewUser readonly & record {
    # The `name` of the User
    string name;
    # The `age` of the User
    int age;
};

# Represents the NewPost type in the GraphQL schema.
type NewPost readonly & record {|
    # The `title` of the Post
    string title;
    # The `content` of the Post
    string content;
|};
