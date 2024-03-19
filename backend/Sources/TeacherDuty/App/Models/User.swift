import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class User: Model, Content {
    static let schema = "Users"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @ID(custom: "externalIDText", generatedBy: .database)
    var externalIDText: String?
    
    @Field(key: "firstName")
    var firstName: String

    @Field(key: "lastName")
    var lastName: String
    
    @Field(key: "emailAddress")
    var email: String

    @Children(for: \.$user)
    var authenticators: [UserAuthentication]

    @Timestamp(key: "creationTimestamp", on: .create)
    var creationTimestamp: Date?

    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    @OptionalField(key: "supplementaryJSON")
    var supplementaryJSON: Availability?

    @Children(for: \.$user)
    var shifts: [UserShifts]

    init() { }

    struct Availability : Content {
        var periods: [Int?]
    }

    func hasPassword() -> Bool {
        return authenticators.contains(where: { $0.isPassword() && $0.isActive() })
    }

    func getPasswordAuthenticator(returnNullableToken: Bool = false) -> UserAuthentication? {
        return authenticators.first(where: { (returnNullableToken || $0.isActive()) && $0.isPassword() })
    }
}

extension User {
    struct Email: Content {
        var firstName: String
        var lastName: String
        var email: String
    }

    struct Patch: Decodable {
        var firstName: String?
        var lastName: String?
        var email: String?
    }
        
    struct Verify: Content{
        var password: String
        var confirmPassword : String
        var token: String
    }
    
    struct Login: Content {
        var userID: String
    }
    
    struct Remove: Content {
        var id: Int?
    }
}

extension User.Email: Validatable{
    static func validations(_ validations: inout Validations){
        validations.add("firstName", as: String.self, is: !.empty)
        validations.add("lastName", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .allenEmail)
    }
}

extension User.Verify: Validatable{
    static func validations(_ validations: inout Validations){
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension User: SessionAuthenticatable {
    private var sessionID: Int?
    {
        self.id!
    }
}


// Make login sessionable
extension User: ModelSessionAuthenticatable { }
