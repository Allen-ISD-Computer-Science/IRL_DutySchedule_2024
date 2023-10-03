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
    var context: Context

    @Field(key: "day")
    var day: Date

    @OptionalField(key: "dayOfWeek")
    var dayOfWeek: Int?

    @OptionalField(key: "supplementaryJSON")
    var supplementaryJSON: OptionalSupplementaryJSON
   
    @Timestamp(key: "creationTimestamp", on: .create)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    init() { }

    struct DayType : Content {
        var abDay: String?
    }
}
