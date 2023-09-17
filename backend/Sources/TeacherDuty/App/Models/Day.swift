import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Day: Model, Content {
    static let schema = "Days"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @Parent(key: "contextID")
    var contextID: Context

    @Field(key: "day")
    var day: Date

    @OptionalField(key: "dayOfWeek")
    var dayOfWeek: Int?

    @Field(key: "supplementaryJSON")
    var supplementaryJSON: Data
   
    @Timestamp(key: "creationTimestamp", on: .create, format: .default)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modifcationTimestamp", on: .update, format: .default)
    var modificationTimestamp: Date?

    init() { }
}
