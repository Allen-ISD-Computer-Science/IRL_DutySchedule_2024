import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Duty: Model, Content {
    static let schema = "Duties"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @Parent(key: "contextID")
    var context: Context
    
    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @OptionalField(key: "supplementaryJSON")
    var supplementaryJSON: OptionalSupplementaryJSON

    @Timestamp(key: "creationTimestamp", on: .create)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    init() { }
}
