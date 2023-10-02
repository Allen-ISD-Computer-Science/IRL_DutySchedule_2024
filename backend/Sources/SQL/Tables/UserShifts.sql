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
-- UserShifts
-- UserShifts within a context associate a specific user with a specific shift
-- ================================================================================================
CREATE TABLE UserShifts (
    id INT NOT NULL AUTO_INCREMENT,
    externalID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
    
    userID INT NOT NULL,
    shiftID INT NOT NULL,
    supplementaryJSON JSON NULL DEFAULT NULL,

    creationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modificationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT PK_UserShifts_id PRIMARY KEY (id),
    CONSTRAINT UK_UserShifts_externalID UNIQUE (externalID),
    CONSTRAINT FK_UserShifts_userID FOREIGN KEY (userID) REFERENCES Users(id),
    CONSTRAINT FK_UserShifts_shiftID FOREIGN KEY (shiftID) REFERENCES Shifts(id)
);

-- Triggers for UserShifts 
DELIMITER //
CREATE TRIGGER trigger_UserShifts_Insert
BEFORE INSERT ON UserShifts 
FOR EACH ROW
BEGIN
    DECLARE userContextID INT;
    DECLARE shiftContextID INT;

    DECLARE error_context_id_mismatch CONDITION FOR SQLSTATE '45000';

    SELECT contextID INTO userContextID FROM Users WHERE userID = NEW.userID;
    SELECT contextID INTO shiftContextID FROM Shifts WHERE shiftID = NEW.shiftID;

    IF userContextID != shiftContextID THEN
        SIGNAL error_context_id_mismatch;
    END IF;
END;	
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trigger_UserShifts_Update
BEFORE UPDATE ON UserShifts  
FOR EACH ROW
BEGIN
    DECLARE userContextID INT;
    DECLARE shiftContextID INT;

    DECLARE error_context_id_mismatch CONDITION FOR SQLSTATE '45000';
    
    SELECT contextID INTO userContextID FROM Users WHERE userID = NEW.userID;
    SELECT contextID INTO shiftContextID FROM Shifts WHERE shiftID = NEW.shiftID;

    IF userContextID != shiftContextID THEN
        SIGNAL error_context_id_mismatch;
    END IF;
END;    
//
DELIMITER ;

