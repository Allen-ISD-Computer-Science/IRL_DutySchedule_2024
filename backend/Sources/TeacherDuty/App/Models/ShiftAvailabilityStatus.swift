import Vapor
import Fluent
import FluentMySQLDriver

final class ShiftAvailabilityStatus: Model, Content {
    static let schema = "ShiftAvailabilityStatus_WithID"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "shiftExternalID")
    var shiftExternalID: UUID?

    @Field(key: "shiftID")
    var shiftID: Int

    @Field(key: "shiftExternalIDText")
    var shiftExternalIDText: String

    @Parent(key: "shiftDayID")
    var shiftDayID: Day

    @Parent(key: "shiftPositionID")
    var shiftPositionID: Position

    @Field(key: "shiftStartTime")
    var shiftStartTime: Time

    @Field(key: "shiftEndTime")
    var shiftEndTime: Time

    @OptionalField(key: "shiftSupplementaryJSON")
    var shiftSupplementaryJSON: OptionalSupplementaryJSON

    @Field(key: "userShiftID")
    var userShiftID: Int

    @Field(key: "userShiftExternalID")
    var userExternalID: UUID?

    @Field(key: "userShiftExternalIDText")
    var userExternalIDText: String

    @Field(key: "userShiftUserID")
    var userShiftUserID: Int

    @OptionalField(key: "userShiftSupplementaryJSON")
    var userShiftSupplementaryJSON: OptionalSupplementaryJSON

    @Field(key: "fulfilledStatus")
    var fulfilledStatus: String
}
