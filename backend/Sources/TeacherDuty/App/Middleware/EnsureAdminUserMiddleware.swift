import Vapor

struct EnsureAdminUserMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let user = request.auth.get(User.self) else { // TODO FIX
            throw Abort(.unauthorized)
        }
        return try await next.respond(to: request)
    }
}
