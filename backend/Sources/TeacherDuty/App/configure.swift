// Copyright (C) 2023 Muqadam Sabir, Ryan Hallock, Brett Kaplan
//                    David Ben-Yaakov 
// This program was developed using codermerlin.academy resources.
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see https://www.gnu.org/licenses/.

import Vapor
import Leaf
import Fluent
import FluentMySQLDriver
import MultipartKit

func configure(_ app: Application) throws {
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)

    // Configuration
    //app.mailgun.configuration = .init(apiKey: getEnvString("MAILGUN_APIKEY"))
    //app.mailgun.defaultDomain = MailgunDomain(getEnvString("MAILGUN_DOMAIN"), .us)

    //Gatekeeper
    app.caches.use(.memory)
    app.gatekeeper.config = .init(maxRequests: 32, per: .second)
    app.middleware.use(GatekeeperMiddleware())
    app.gatekeeper.keyMakers.use(.userID)
    
    var tls = TLSConfiguration.makeClientConfiguration()
    tls.certificateVerification = .none

    let globalConfiguration = GlobalConfiguration.cached
    app.databases.use(.mysql(
                        hostname: globalConfiguration.mysqlHostname,
                        port: globalConfiguration.mysqlPort,
                        username: globalConfiguration.mysqlUsername,
                        password: globalConfiguration.mysqlPassword,
                        database: globalConfiguration.mysqlDatabase,
                        tlsConfiguration: tls
                      ), as: .mysql)

    app.http.server.configuration.hostname = globalConfiguration.vaporLocalHost
    app.http.server.configuration.port = globalConfiguration.vaporLocalPort

    // Reigster Migrations
    //app.migrations.add(User.Migration())

    // register routes
    try routes(app)
}
    
