import Vapor
import Fluent

final class Shift: Model, Content {
    static let schema = "Shifts"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @ID(custom: "externalIDText", generatedBy: .database)
    var externalIDText: String?
    
    @Parent(key: "dayID")
    var day: Day

    @Parent(key: "positionID")
    var position: Position

    @Field(key: "startTime")
    var start: Time

    @Field(key: "endTime")
    var end: Time

    @OptionalField(key: "supplementaryJSON")
    var supplementaryJSON: OptionalSupplementaryJSON

    @Timestamp(key: "creationTimestamp", on: .create)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    init() { }

}
