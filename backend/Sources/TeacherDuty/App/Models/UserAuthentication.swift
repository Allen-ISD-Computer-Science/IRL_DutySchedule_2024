import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class UserAuthentication: Model, Content {
    static let schema = "UserAuthentication"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @Parent(key: "userID")
    var user: User

    @Field(key: "token")
    var token: String?

    @OptionalField(key: "resetToken")
    var resetToken: String?

    @Timestamp(key: "resetTimestamp", on: .none)
    var resetTimestamp: Date?

    @OptionalField(key: "supplementaryJSON")
    var supplementaryJSON: OptionalSupplementaryJSON

    @Timestamp(key: "creationTimestamp", on: .create)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    func isActive() -> Bool {
        return token != nil
    }

    func isPassword() -> Bool {
        return supplementaryJSON == nil
    }

    init() { }

}
