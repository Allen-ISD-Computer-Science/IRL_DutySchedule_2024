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
-- Availability
-- Availability contains available days and times within a specific context
-- ================================================================================================
CREATE TABLE Availability (
    id INT NOT NULL AUTO_INCREMENT,
    externalID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),

    contextID INT NOT NULL,
    
    dayID INT NOT NULL,
    supplementaryJSON JSON NOT NULL DEFAULT ("{}"),

    startTime TIME NOT NULL,
    endTime TIME NOT NULL,

    creationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modificationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT PK_Availability_id PRIMARY KEY (id),
    CONSTRAINT UK_Availability_externalID UNIQUE (externalID),
    CONSTRAINT FK_Availability_contextID FOREIGN KEY (contextID) REFERENCES Contexts(id),
    CONSTRAINT FK_Availability_dayID FOREIGN KEY (dayID) REFERENCES Days(id),
    CONSTRAINT CK_Availability_startTime_endTime CHECK (startTime < endTime)
);

