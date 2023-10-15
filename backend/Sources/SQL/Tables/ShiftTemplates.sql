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
-- ShiftTemplates
-- ShiftTemplates represent a range of time within a specific context for which a Shift may be created
-- ================================================================================================
CREATE TABLE ShiftTemplates (
    id INT NOT NULL AUTO_INCREMENT,
    externalID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
    externalIDText VARCHAR(36) GENERATED ALWAYS AS (BIN_TO_UUID(externalID)),

    contextID INT NOT NULL,

    startTime TIME NOT NULL,
    endTime TIME NOT NULL,

    name VARCHAR(64) NOT NULL,
    description TEXT NULL DEFAULT NULL,
    supplementaryJSON JSON NULL DEFAULT NULL,

    creationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modificationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT PK_ShiftTemplates_id PRIMARY KEY (id),
    CONSTRAINT UK_ShiftTemplates_externalID UNIQUE (externalID),
    CONSTRAINT UK_ShiftTemplates_contextID_name UNIQUE(contextID, name),
    CONSTRAINT FK_ShiftTemplates_contextID FOREIGN KEY (contextID) REFERENCES Contexts(id),
    CONSTRAINT CK_ShiftTemplates_startTime_endTime CHECK (startTime < endTime)
);
