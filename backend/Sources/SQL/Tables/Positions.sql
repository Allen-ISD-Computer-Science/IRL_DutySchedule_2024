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
-- Positions
-- Positions are a duty at a specific location
-- Examples: "Sous Chef at Paris Branch", "Head Chef at Store #5231"
-- ================================================================================================
CREATE TABLE Positions (
    id INT NOT NULL AUTO_INCREMENT,
    externalID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
    
    dutyID INT NOT NULL,
    locationID INT NOT NULL,
    supplementaryJSON JSON NULL DEFAULT NULL,
    
    creationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modificationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT PK_Positions_id PRIMARY KEY (id),
    CONSTRAINT UK_Positions_externalID UNIQUE (externalID),
    CONSTRAINT FK_Positions_dutyID FOREIGN KEY (dutyID) REFERENCES Duties(id),
    CONSTRAINT FK_Positions_locationID FOREIGN KEY (locationID) REFERENCES Locations(id)
);

-- Triggers for Positions 
DELIMITER //
CREATE TRIGGER trigger_Positions_Insert
BEFORE INSERT ON Positions 
FOR EACH ROW
BEGIN
    DECLARE dutyContextID INT;
    DECLARE locationContextID INT;

    DECLARE error_context_id_mismatch CONDITION FOR SQLSTATE '45000';

    SELECT contextID INTO dutyContextID FROM Duties WHERE dutyID = NEW.dutyID;
    SELECT contextID INTO locationContextID FROM Locations WHERE locationID = NEW.locationID;

    IF dutyContextID != locationContextID THEN
        SIGNAL error_context_id_mismatch;
    END IF;
END;	
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trigger_Positions_Update
BEFORE UPDATE ON Positions  
FOR EACH ROW
BEGIN
    DECLARE dutyContextID INT;
    DECLARE locationContextID INT;

    DECLARE error_context_id_mismatch CONDITION FOR SQLSTATE '45000';
    
    SELECT contextID INTO dutyContextID FROM Duties WHERE dutyID = NEW.dutyID;
    SELECT contextID INTO locationContextID FROM Locations WHERE locationID = NEW.locationID;

    IF dutyContextID != locationContextID THEN
        SIGNAL error_context_id_mismatch;
    END IF;
END;    
//
DELIMITER ;

