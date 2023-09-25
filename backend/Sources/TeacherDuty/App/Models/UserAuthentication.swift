import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class UserAuthentication: Model, Content {
    static let schema = "UserAuthentication"
    typealias JSONData = [String: String]

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

    @Field(key: "supplementaryJSON")
    var supplementaryJSON: JSONData

    @Timestamp(key: "creationTimestamp", on: .create)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    func isPasswordActive() -> Bool {
        return isPassword() && token != nil
    }

    func isPassword() -> Bool {
        return supplementaryJSON.isEmpty
    }

    init() { }

}
