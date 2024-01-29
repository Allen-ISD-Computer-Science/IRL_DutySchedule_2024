
import Vapor
import Fluent
import FluentMySQLDriver

final class UsersWithMatchingAvailabilityForShift: Model, Content {
    static let schema = "UsersWithMatchingAvailabilityForShift_WithID"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "shiftID")
    var shiftID: Int

    @Field(key: "shiftExternalID")
    var shiftExternalID: UUID

    @OptionalField(key: "shiftExternalIDText")
    var shiftExternalIDText: String?

    @Field(key: "shiftStartTime")
    var shiftStartTime: String

    @Field(key: "shiftEndTime")
    var shiftEndTime: String

    @OptionalField(key: "shiftSupplementaryJSON")
    var shiftSupplementaryJSON: OptionalSupplementaryJSON?

    @Field(key: "contextID")
    var contextID: Int

    @Field(key: "contextExternalID")
    var contextExternalID: UUID

    @OptionalField(key: "contextExternalIDText")
    var contextExternalIDText: String?

    @Field(key: "contextName")
    var contextName: String

    @OptionalField(key: "contextSupplementaryJSON")
    var contextSupplementaryJSON: OptionalSupplementaryJSON?

    @Field(key: "dayID")
    var dayID: Int

    @Field(key: "dayExternalID")
    var dayExternalID: UUID

    @OptionalField(key: "dayExternalIDText")
    var dayExternalIDText: String?

    @Field(key: "dayDay")
    var dayDay: Date

    @OptionalField(key: "daySupplementaryJSON")
    var daySupplementaryJSON: OptionalSupplementaryJSON
    
    @OptionalField(key: "dayDayOfWeek")
    var dayDayOfWeek: Int?

    @Field(key: "positionID")
    var positionID: Int

    @Field(key: "positionExternalID")
    var positionExternalID: UUID

    @OptionalField(key: "positionExternalIDText")
    var positionExternalIDText: String?

    @Field(key: "dutyID")
    var dutyID: Int

    @Field(key: "dutyExternalID")
    var dutyExternalID: UUID
    
    @OptionalField(key: "dutyExternalIDText")
    var dutyExternalIDText: String?
    
    @Field(key: "dutyName")
    var dutyName: String
    
    @Field(key: "dutyDescription")
    var dutyDescription: String
    
    @OptionalField(key: "dutySupplementaryJSON")
    var dutySupplementaryJSON: OptionalSupplementaryJSON
    
    @Field(key: "locationID")
    var locationID: Int
    
    @Field(key: "locationExternalID")
    var locationExternalID: UUID
    
    @OptionalField(key: "locationExternalIDText")
    var locationExternalIDText: String?
    
    @Field(key: "locationName")
    var locationName: String
    
    @Field(key: "locationDescription")
    var locationDescription: String
    
    @OptionalField(key: "locationSupplementaryJSON")
    var locationSupplementaryJSON: OptionalSupplementaryJSON
    
    @Field(key: "availabilityID")
    var availabilityID: Int
    
    @Field(key: "availabilityExternalID")
    var availabilityExternalID: UUID
    
    @OptionalField(key: "availabilityExternalIDText")
    var availabilityExternalIDText: String?
    
    @OptionalField(key: "availabilitySupplementaryJSON")
    var availabilitySupplementaryJSON: OptionalSupplementaryJSON
    
    @Field(key: "availabilityStartTime")
    var availabilityStartTime: String
    
    @Field(key: "availabilityEndTime")
    var availabilityEndTime: String
    
    @Field(key: "userID")
    var userID: Int
    
    @Field(key: "userExternalID")
    var userExternalID: UUID
    
    @OptionalField(key: "userExternalIDText")
    var userExternalIDText: String?
    
    @Field(key: "userFirstName")
    var userFirstName: String
    
    @Field(key: "userLastName")
    var userLastName: String
    
    @Field(key: "userEmailAddress")
    var userEmailAddress: String
    
    @OptionalField(key: "userSupplementaryJSON")
    var userSupplementaryJSON: OptionalSupplementaryJSON
    
}
