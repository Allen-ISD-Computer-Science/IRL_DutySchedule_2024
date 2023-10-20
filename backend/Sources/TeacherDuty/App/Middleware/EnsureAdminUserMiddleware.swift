import Vapor
import Fluent

struct EnsureAdminUserMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let user = request.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }

        let userRole = try await UserRoles.query(on: request.db)
          .join(User.self, on: \UserRoles.$user.$id == \User.$id)
          .filter(User.self, \.$id == user.id!)
          .first()
        
        if userRole!.$role.value == nil { // Check to see if role is loaded.
            try await userRole!.$role.load(on: request.db)
        } // Continue

        let adminRole = try await Role.adminRole(on: request.db)

        guard userRole!.role == adminRole else {
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
