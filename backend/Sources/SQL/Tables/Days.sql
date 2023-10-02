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
-- Days
-- Days are a date within a specific context for which duty is required
-- ================================================================================================
CREATE TABLE Days (
    id INT NOT NULL AUTO_INCREMENT,
    externalID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
    
    contextID INT NOT NULL,

    day DATE NOT NULL,
    supplementaryJSON JSON NULL DEFAULT NULL,

    dayOfWeek INT AS (DAYOFWEEK(day)),  -- 1=Sunday ... 7=Saturday

    creationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modificationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT PK_Days_id PRIMARY KEY (id),
    CONSTRAINT UK_Days_externalID UNIQUE (externalID),
    CONSTRAINT FK_Days_contextID FOREIGN KEY (contextID) REFERENCES Contexts(id)
);


