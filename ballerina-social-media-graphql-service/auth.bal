import ballerina/graphql;

isolated function authenticate(graphql:Context context) returns string|error {
    string? token = getToken(context);
    if token is string {
        return token;
    } else {
        return error("Not authenticated");
    }
}

isolated function authorize(string token, string id) returns error? {
    if token != id {
        return error("Not authorized");
    }
}
