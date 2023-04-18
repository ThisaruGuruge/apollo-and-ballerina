import ballerina/graphql;

isolated function authenticate(graphql:Context context) returns string|error {
    string token = check getToken(context);
    _ = check authenticateUserToken(token);
    return token;
}

// TODO: Using the same DB for authentication. This can be improved by using a separate DB for authentication.
isolated function authenticateUserToken(string token) returns error? {
    // Get the user from the token
    UserData|error user = getUser(token);
    if user is error {
        return error("Not authenticated");
    }
}

isolated function authorize(string token, string id) returns error? {
    if token != id {
        return error("Not authorized");
    }
}
