import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Availability: Model, Content {
    static let schema = "Availability"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @Parent(key: "contextID")
    var context: Context

    @Parent(key: "dayID")
    var day: Day

    @Field(key: "startTime")
    var start: Date

    @Field(key: "endTime")
    var end: Date

    @OptionalField(key: "supplementaryJSON")
    var supplementaryJSON: OptionalSupplementaryJSON

    @Timestamp(key: "creationTimestamp", on: .create)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    init() { }

}

extension Availability: Contextable {
    static let contextKey = \Availability.$context.$id
}
