import Vapor

struct EmailContact: Encodable {
    let firstName: String?
    let lastName: String?
    let emailAddress: String
}

struct EmailData: Encodable {
    let contact: EmailContact
    let templateExternalID: String
    let templateParameters: any Encodable

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(contact, forKey: .contact)
        try container.encode(templateExternalID, forKey: .templateExternalID)

        // The rest of it is just trying to format it correctly for the EmailAPI (requires json to be in string form for parameters.)

        // Next 3 lines just try to use the vapor's encoder (incase its changed.)
        var byteBuffer = ByteBuffer()
        var headers = HTTPHeaders()
        try ContentConfiguration.global.requireEncoder(for: .json).encode(templateParameters, to: &byteBuffer, headers: &headers)

        guard let encapsulatedJSON  = String(data: Data(buffer: byteBuffer), encoding: .utf8) else {
            throw GlobalEmailAPI.EmailError.encodingError
        }

        try container.encode(encapsulatedJSON, forKey: .templateParameters)
    }

    private enum CodingKeys: String, CodingKey {
        case contact
        case templateExternalID
        case templateParameters
    }
}

protocol EmailContactConsumer {
    func createContent(with contact: EmailContact) -> any Encodable
}

struct GlobalEmailAPI {

    enum EmailError: Error {
        case serverError(reason: String)

        case encodingError

        // Called when the email doesnt follow the user Email, validator.
        case unsupportedEmail
    }

    struct ServerErrorContent: Content {
        let reason: String
        let error: Bool
    }

    static func sendEmail(from request: Request, with emailData: EmailData) async throws {
        // Verfiy email using the original allenEmail validator.
        guard !Validator.allenEmail.validate(emailData.contact.emailAddress).isFailure else {
            throw EmailError.unsupportedEmail
        }

        let response: ClientResponse = try await request.client.post(GlobalConfiguration.cached.notificationAPIURI) { req in
            try req.content.encode(emailData, as: .json)

            req.headers.add(name: "apiKey", value: GlobalConfiguration.cached.notificationAPIKey)
        }

        guard response.status == .ok else {
            switch app.environment {
            case .development, .testing:
                guard let reason = try? response.content.decode(ServerErrorContent.self).reason else {
                    throw EmailError.serverError(reason: "Email API failed to process request because of a undecodable reason.")
                }

                throw EmailError.serverError(reason: "Email API failed to process request because of `\(reason)`")
            default:
                throw EmailError.serverError(reason: "Email API failed to process request.")
            }
        }

        request.logger.info("Sucessfully sent email to \(emailData.contact.emailAddress)")
    }
}
