import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Position: Model, Content {
    static let schema = "Positions"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @Parent(key: "dutyID")
    var duty: Duty

    @Parent(key: "locationID")
    var location: Location

    @Field(key: "supplementaryJSON")
    var supplementaryJSON: Data

    @Timestamp(key: "creationTimestamp", on: .create, format: .default)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    init() { }
}
