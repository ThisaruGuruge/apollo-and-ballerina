import { getUser } from "../db/db.js";
import { User } from "../types/user.js";

// TODO: Using the same DB for authentication. This can be improved by using a separate DB for authentication.
export const getAuthenticatedUser = async function (token: string): Promise<User> {
    return await getUser(token);
}

export function authenticate(token: string) {
    if (!token) {
        throw new Error("Not authenticated");
    }
}

export function authorize(token: string, id: string) {
    if (token !== id) {
        throw new Error("Not authorized");
    }
}
