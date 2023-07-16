import Vapor
import Fluent

final public class Subject: Model, Content {
    public static let schema = "Subjects"

    @ID(custom: "subject_id", generatedBy: .database)
    public var id: Int?

    @OptionalField(key: "code_prefix")
    public var codePrefix: String?

    @OptionalField(key: "subject")
    public var subject: String?

    public init() { }

}
