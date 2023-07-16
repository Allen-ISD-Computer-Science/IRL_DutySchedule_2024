import Vapor
import Fluent

final public class Section: Model, Content {
    public static let schema = "Sections"

    @ID(custom: "section_id", generatedBy: .database)
    public var id: Int?

    @Parent(key: "teacher_id") // Has to have a parent or is worthless.
    public var teacher: TeacherInfo

    @OptionalField(key: "period")
    public var period: Int?

    @OptionalField(key: "class_code")
    public var classCode: Int?

    @OptionalField(key: "semester")
    public var semester: String?

    public init() {}

    // Use this to create a parent.
    public init(teacherId: TeacherInfo.IDValue) {
        self.$teacher.id = teacherId
    }

}
