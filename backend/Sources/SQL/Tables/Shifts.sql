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
-- Shifts
-- Shifts are a time and position within a specific context for which duty is required
-- ================================================================================================
CREATE TABLE Shifts (
    id INT NOT NULL AUTO_INCREMENT,
    externalID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
    externalIDText VARCHAR(36) GENERATED ALWAYS AS (BIN_TO_UUID(externalID)),
    
    dayID INT NOT NULL,
    positionID INT NOT NULL,

    startTime CHAR(8) NOT NULL, -- Formatted as 01:23:45
    endTime CHAR(8) NOT NULL,

    supplementaryJSON JSON NULL DEFAULT NULL,

    creationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modificationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT PK_Shifts_id PRIMARY KEY (id),
    CONSTRAINT UK_Shifts_externalID UNIQUE (externalID),
    CONSTRAINT FK_Shifts_dayID FOREIGN KEY (dayID) REFERENCES Days(id),
    CONSTRAINT FK_Shifts_positionID FOREIGN KEY (positionID) REFERENCES Positions(id),
    CONSTRAINT CK_Shifts_startTime CHECK (LENGTH(startTime) = 8 AND TIME(startTime) IS NOT NULL),
    CONSTRAINT CK_Shifts_endTime CHECK (LENGTH(endTime) = 8 AND TIME(endTime) IS NOT NULL),
    CONSTRAINT CK_Shifts_startTime_endTime CHECK (TIME(startTime) < TIME(endTime))
);

-- Triggers for Shifts 
DELIMITER //
CREATE TRIGGER trigger_Shifts_Insert
BEFORE INSERT ON Shifts 
FOR EACH ROW
BEGIN
    DECLARE dayContextID INT;
    DECLARE positionContextID INT;

    DECLARE error_context_id_mismatch CONDITION FOR SQLSTATE '45000';

    SELECT contextID INTO dayContextID FROM Days WHERE id = NEW.dayID;
    SELECT d.contextID INTO positionContextID FROM Positions p INNER JOIN Duties d ON p.dutyID = d.id WHERE p.id = NEW.positionID;

    IF dayContextID != positionContextID THEN
        SIGNAL error_context_id_mismatch;
    END IF;
END;	
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trigger_Shifts_Update
BEFORE UPDATE ON Shifts  
FOR EACH ROW
BEGIN
    DECLARE dayContextID INT;
    DECLARE positionContextID INT;

    DECLARE error_context_id_mismatch CONDITION FOR SQLSTATE '45000';
    
    SELECT contextID INTO dayContextID FROM Days WHERE id = NEW.dayID;
    SELECT d.contextID INTO positionContextID FROM Positions p INNER JOIN Duties d ON p.dutyID = d.id WHERE p.id = NEW.positionID;

    IF dayContextID != positionContextID THEN
        SIGNAL error_context_id_mismatch;
    END IF;
END;    
//
DELIMITER ;

