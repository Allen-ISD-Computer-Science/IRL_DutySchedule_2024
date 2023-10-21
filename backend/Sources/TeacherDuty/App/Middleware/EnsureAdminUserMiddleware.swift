import Vapor
import Fluent

struct EnsureAdminUserMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let user = request.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }

        guard let userId = user.id else {
            app.logger.warning("User `\(user.email)` does not have id field.")
            throw Abort(.expectationFailed)
        }

        guard let adminRoleId = try await Role.adminRole(on: request.db).id else {
            app.logger.critical("Admin role not located.")
            throw Abort(.expectationFailed)
        }

        guard try await UserRoles.query(on: request.db)
                .filter(\.$user.$id == userId)
                .filter(\.$role.$id == adminRoleId)
                .count() == 1 else {
            // User does not have the admin role.
            throw Abort(.unauthorized)
        }

        return try await next.respond(to: request)
    }
}
