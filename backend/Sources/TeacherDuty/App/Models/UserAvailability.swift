import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class UserAvailability: Model, Content {
    static let schema = "UserAvailability"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @ID(custom: "externalIDText", generatedBy: .database)
    var externalIDText: String?

    @Parent(key: "availabilityID")
    var availability: Availability

    @Parent(key: "userID")
    var user: User

    @OptionalField(key: "supplementaryJSON")
    var supplementaryJSON: OptionalSupplementaryJSON

    @Timestamp(key: "creationTimestamp", on: .create)
    var creationTimestamp: Date?

    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    init() { }

}


