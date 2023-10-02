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
-- Users
-- Users within a context
-- ================================================================================================
CREATE TABLE Users (
    id INT NOT NULL AUTO_INCREMENT,
    externalID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
    
    roleID INT NOT NULL,
    
    firstName VARCHAR(32) NOT NULL,
    lastName VARCHAR(32) NOT NULL,
    emailAddress VARCHAR(64) NOT NULL,
    supplementaryJSON JSON NULL DEFAULT NULL,
    
    creationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modificationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT PK_Users_id PRIMARY KEY (id),
    CONSTRAINT UK_Users_externalID UNIQUE (externalID),
    CONSTRAINT FK_Users_roleID FOREIGN KEY (roleID) REFERENCES Roles(id),
    CONSTRAINT UK_Users_roleID_emailAddress UNIQUE (roleID, emailAddress)
);


