/*
VaporShell provides a minimal framework for starting Vapor projects.
Copyright (C) 2021, 2022 CoderMerlin.com
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import Vapor
import Fluent
import FluentMySQLDriver

// configures your application
func configure(_ app: Application) throws {
    // UNCOMMENT-PUBLIC to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    var tls = TLSConfiguration.makeClientConfiguration()
    tls.certificateVerification = .none
    app.databases.use(.mysql(
                        hostname: getEnviormentVaraible("VAPOR_SQL_HOSTNAME", defaultValue:"db"),
                        port: MySQLConfiguration.ianaPortNumber,
                        username: getEnviormentVaraible("VAPOR_SQL_USERNAME"),
                        password: getEnviormentVaraible("VAPOR_SQL_PASSWORD"),
                        database: getEnviormentVaraible("VAPOR_SQL_DATABASE"),
                        tlsConfiguration: tls
                      ), as: .mysql)

    // Set local port
    guard let portString = Environment.get("VAPOR_LOCAL_PORT"),
          let port = Int(portString) else {
        fatalError("Failed to determine VAPOR LOCAL PORT from environment")
    }
    app.http.server.configuration.port = port

    // Set local host
    guard let hostname = Environment.get("VAPOR_LOCAL_HOST") else {
        fatalError("Failed to determine VAPOR LOCAL HOST from environment")
    }
    app.http.server.configuration.hostname = hostname

    // register routes
    try routes(app)
}

func getEnviormentVaraible(_ key: String, defaultValue: String? = nil) -> String {
    guard let value = Environment.get(key) ?? defaultValue else {
        fatalError("Could not find a value for key `\(key) inside the enviorment variables. Check your .env file`")
    }

    guard value != defaultValue else {
        app.logger.log(level: .warning, "Using default return value for `\(key)`.")
        return value
    }

    return value
}
