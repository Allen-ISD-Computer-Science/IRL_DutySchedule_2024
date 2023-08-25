import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class User: Model, Content {
    static let schema = "users"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @Field(key: "name")
    var name: String?
    
    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    @Field(key: "accessToken")
    var token: String?

    @Field(key: "isActive")
    var isActive: Int

    @Timestamp(key: "updatedAt", on: .update, format: .default)
    var updatedAt: Date?
    
    @Timestamp(key: "forgotMailSentAt", on: .update, format: .default)
    var forgotMailSentAt: Date?

    @Field(key: "canView")
    var canView: Int

    @Field(key: "canEdit")
    var canEdit: Int

    @Field(key: "isAdmin")
    var isAdmin: Int

    //@Timestamp(key: "updatedAt", on: .update, format: .default)
    //var updatedAt: Date?
          
    init() { }

    init(id: Int? = nil, name: String? = nil, email: String, passwordHash: String, token: String? = nil, isActive: Int = 0, updatedAt: Date? = nil, forgotMailSentAt: Date? = nil, canView: Int = 1, canEdit: Int = 0, isAdmin: Int = 0) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.token = token
        self.isActive = isActive
        self.updatedAt = updatedAt
        self.forgotMailSentAt = forgotMailSentAt
        self.canView = canView
        self.canEdit = canEdit
        self.isAdmin = isAdmin
    }

    
       
}

extension User {
    struct Email: Content {
        var firstName: String
        var lastName: String
        var email: String
    }

    struct Verify: Content{
        var password: String
        var confirmPassword : String
        var token: String
    }
    
    struct Login: Content {
        var userID: String
    }
    struct Create: Content {
        var name: String
        var canView: Bool
        var canEdit: Bool
        var isAdmin: Bool
    }
    struct Remove: Content {
        var id: Int?
    }
}

extension User.Email: Validatable{
    static func validations(_ validations: inout Validations){
        validations.add("firstName", as: String.self, is:!.empty)
        validations.add("lastName", as: String.self, is:!.empty)
        validations.add("email", as: String.self, is:!.empty)
    }
}

extension User.Verify: Validatable{
    static func validations(_ validations: inout Validations){
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email 
    static let passwordHashKey = \User.$passwordHash
    
    func verify(email: String) throws -> Bool {
        let emailData = Data(email.utf8)
        let hashedEmail = SHA256.hash(data: emailData)
        if (hashedEmail.hex == self.email){
//            print("HASHES MATCH! \n HASH: \(hashedEmail.hex) \n EXPECTED HASH: \(self.email)")
            return true
        }
        else {
  //          print("HASHES DO NOT MATCH! \n HASH: \(hashedEmail.hex) \n EXPECTED HASH: \(self.email)")
            return false
        }
    }
     
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
        
    }
}

extension User: SessionAuthenticatable {
    var sessionID: Int?
    {
        self.id!
    }
}


// Make login sessionable
extension User: ModelSessionAuthenticatable { }
extension User: ModelCustomAuthenticatable {}

