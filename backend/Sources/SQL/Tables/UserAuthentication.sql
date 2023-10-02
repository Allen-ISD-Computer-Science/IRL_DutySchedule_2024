-- Copyright (C) 2023 Ryan Hallock, Muqadam Sabir, David Ben-Yaakov
-- This program was developed using codermerlin.academy resources.
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see https://www.gnu.org/licenses/.

-- ================================================================================================
-- UserAuthentication
-- UserAuthentication contains the way the user is able to login, should support SSO through supplmentary
-- ================================================================================================
CREATE TABLE UserAuthentication (
    id INT NOT NULL AUTO_INCREMENT,
    externalID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),

    userID INT NOT NULL,

    token varchar(255) NULL DEFAULT NULL,

    resetToken varchar(64) NULL DEFAULT NULL,
    resetTimestamp DATETIME NULL DEFAULT NULL,

    supplementaryJSON JSON NULL DEFAULT NULL,

    creationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modificationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT PK_UserAuthentication_id PRIMARY KEY (id),
    CONSTRAINT UK_UserAuthentication_externalID UNIQUE (externalID),
    CONSTRAINT FK_UserAuthentication_userID FOREIGN KEY (userID) REFERENCES Users(id),
    CONSTRAINT UK_UserAuthentication_resetToken UNIQUE (resetToken)
);
