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
-- Locations
-- Locations within a context in which duties occur
-- Examples: "Paris Branch", "Store #5231"
-- ================================================================================================
CREATE TABLE Locations (
    id INT NOT NULL AUTO_INCREMENT,
    externalID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
    
    contextID INT NOT NULL,

    name VARCHAR(64) NOT NULL,
    description TEXT NOT NULL,
    supplementaryJSON JSON NOT NULL DEFAULT ('{}'),
    
    creationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modificationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT PK_Locations_id PRIMARY KEY (id),
    CONSTRAINT UK_Locations_externalID UNIQUE (externalID),
    CONSTRAINT FK_Locations_contextID FOREIGN KEY (contextID) REFERENCES Contexts(id)
);



