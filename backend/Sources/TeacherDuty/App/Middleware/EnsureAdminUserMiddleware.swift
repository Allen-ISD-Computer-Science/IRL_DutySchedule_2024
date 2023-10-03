import Vapor

struct EnsureAdminUserMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let user = request.auth.get(User.self)
        if user != nil {
            try await user!.$role.load(on: request.db)
            if user!.role.role != "Administrator" {
                throw Abort(.unauthorized)
            }
        }
        else {
            return try await next.respond(to: request)
        }
        return try await next.respond(to: request)
    }
}
