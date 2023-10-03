import Vapor

struct EnsureAdminUserMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let user = request.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }

        if user.$role.value == nil { // Check to see if role is loaded.
            try await user.$role.load(on: request.db)
        } // Continue

        let adminRole = try await Role.adminRole(on: request.db)

        guard user.role == adminRole else {
            throw Abort(.unauthorized)
        }

        return try await next.respond(to: request)
    }
}


extension Role {
    static func ==(lhs: Role, rhs: Role) -> Bool {
        return lhs.id! == rhs.id! && lhs.role == rhs.role
    }
}
