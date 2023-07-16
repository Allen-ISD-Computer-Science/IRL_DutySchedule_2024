import Vapor
import Fluent

final public class TeacherInfo: Model, Content {
    public static let schema = "Teacher_info"

    @ID(custom: "teacher_id", generatedBy: .database)
    public var id: Int?

    @OptionalField(key: "first_name")
    public var firstName: String?

    @OptionalField(key: "last_name")
    public var lastName: String?

    // Maybe shouldnt be optional?
    @Field(key: "email_address")
    public var email: String?

    @OptionalField(key: "location")
    public var location: String?

    // Children are not really stored here, but are a refrence. @see https://docs.vapor.codes/fluent/relations/#children
    @Children(for: \.$teacher)
    public var sections: [Section]

    public init() { }

}
