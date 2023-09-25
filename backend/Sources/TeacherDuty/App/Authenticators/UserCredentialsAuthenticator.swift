import Vapor
import Fluent

extension User {
  public static func credentialsAuthenticator(
    database: DatabaseID? = nil
  ) -> Authenticator {
    UserCredentialsAuthenticator(database: database)
  }
}


private struct UserCredentialsAuthenticator: CredentialsAuthenticator {

  typealias Credentials = ModelCredentials

  let database: DatabaseID?

  func authenticate(
    credentials: ModelCredentials,
    for request: Request
  ) -> EventLoopFuture<Void> { // Dont know why async authenticators dont work?
    User.query(on: request.db(self.database))
      .filter(\.$email == credentials.username)
      .first()
      .flatMapThrowing { foundUser in
        guard let user = foundUser else {
          return
        }

        guard let password = user.getPasswordAuthenticator()?.token else {
          return
        }

        guard try Bcrypt.verify(credentials.password, created: password) else {
          return
        }

        request.auth.login(user)
      }

  }
}
