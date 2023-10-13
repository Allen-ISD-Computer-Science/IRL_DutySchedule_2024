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
-- Roles
-- Roles which provide privileges to specific users within a context
-- ================================================================================================
CREATE TABLE Roles (
    id INT NOT NULL AUTO_INCREMENT,
    externalID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
    externalIDText VARCHAR(36) GENERATED ALWAYS AS (BIN_TO_UUID(externalID)),

    contextID INT NOT NULL,
    
    role VARCHAR(32) NOT NULL,
    supplementaryJSON JSON NULL DEFAULT NULL,
    
    creationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modificationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT PK_Roles_id PRIMARY KEY (id),
    CONSTRAINT UK_Roles_externalID UNIQUE (externalID),
    CONSTRAINT FK_Roles_contextID FOREIGN KEY (contextID) REFERENCES Contexts(id),
    CONSTRAINT UK_Roles_contextID_role UNIQUE (contextID, role)
);

