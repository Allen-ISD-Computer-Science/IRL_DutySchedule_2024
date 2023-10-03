import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class UserShift: Model, Content {
    static let schema = "UserShifts"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @Parent(key: "userID")
    var user: User

    @Parent(key: "shiftID")
    var shift: Shift

    @OptionalField(key: "supplementaryJSON")
    var supplementaryJSON: OptionalSupplementaryJSON

    @Timestamp(key: "creationTimestamp", on: .create)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    init() { }

}
