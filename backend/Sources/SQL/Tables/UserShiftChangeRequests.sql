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
-- UserShiftChangeRequests
-- UserShiftChangeRequests within a context track requests for shift changes from one
--                         user to another           
-- ================================================================================================
CREATE TABLE UserShiftChangeRequests (
    id INT NOT NULL AUTO_INCREMENT,
    externalID BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),
    
    userShiftID INT NOT NULL,
    requestingUserID INT NOT NULL,
    targetUserID INT NOT NULL,

    requestDate DATETIME NOT NULL DEFAULT NOW(),

    fulfillUserID INT NULL DEFAULT NULL,
    fulfillUserShiftID INT NULL DEFAULT NULL,
    fulfillDate DATETIME NULL DEFAULT NULL,

    denyUserID INT NULL DEFAULT NULL,
    denyDate DATETIME NULL DEFAULT NULL,

    cancelUserID INT NULL DEFAULT NULL,
    cancelDate DATETIME NULL DEFAULT NULL,

    supplementaryJSON JSON NOT NULL DEFAULT ('{}'),

    creationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modificationTimestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT PK_UserShiftChangeRequests_id PRIMARY KEY (id),
    CONSTRAINT UK_UserShiftChangeRequests_externalID UNIQUE (externalID),
    
    CONSTRAINT FK_UserShiftChangeRequests_userShiftID FOREIGN KEY (userShiftID) REFERENCES UserShifts(id),
    CONSTRAINT FK_UserShiftChangeRequests_requestingUserID FOREIGN KEY (requestingUserID) REFERENCES Users(id),
    CONSTRAINT FK_UserShiftChangeRequests_targetUserID FOREIGN KEY (targetUserID) REFERENCES Users(id),
    
    CONSTRAINT FK_UserShiftChangeRequests_fulfillUserShiftID FOREIGN KEY (fulfillUserShiftID) REFERENCES UserShifts(id),

    CONSTRAINT FK_UserShiftChangeRequests_denyUserID FOREIGN KEY (denyUserID) REFERENCES Users(id),

    CONSTRAINT FK_UserShiftChangeRequests_cancelUserID FOREIGN KEY (cancelUserID) REFERENCES Users(id),

    CONSTRAINT CK_UserShiftChangeRequests_fillUID_fillUserShiftID_fulfillDate CHECK
               (((fulfillUserID IS NULL) AND (fulfillUserShiftID IS NULL) AND (fulfillDate IS NULL)) OR
	        ((fulfillUserID IS NOT NULL) AND (fulfillUserShiftID IS NOT NULL) AND (fulfillDate IS NOT NULL))),

    CONSTRAINT CK_UserShiftChangeRequests_denyUserShiftID_denyDate CHECK
               (((denyUserID IS NULL) AND (denyDate IS NULL)) OR
	        ((denyUserID IS NOT NULL) AND (denyDate IS NOT NULL))),

    CONSTRAINT CK_UserShiftChangeRequests_cancelUserID_cancelDate CHECK
               (((cancelUserID IS NULL) AND (cancelDate IS NULL)) OR
	        ((cancelUserID IS NOT NULL) AND (cancelDate IS NOT NULL))),

    CONSTRAINT CK_UserShiftChangeRequests_fulfillUserID_denyUserID_cancelUserID CHECK
    	       (IF(fulfillUserID IS NULL, 0, 1) + IF(denyUserID IS NULL, 0, 1) + IF(cancelUserID IS NULL, 0, 1) BETWEEN 0 AND 1)
);

-- Triggers for UserShiftChangeRequests
DELIMITER //
CREATE TRIGGER trigger_UserShiftChangeRequests_Insert
BEFORE INSERT ON UserShiftChangeRequests
FOR EACH ROW
BEGIN
    DECLARE userShiftContextID INT;
    DECLARE requestingUserContextID INT;
    DECLARE targetUserContextID INT;

    DECLARE error_context_id_mismatch CONDITION FOR SQLSTATE '45000';

    SELECT r.contextID
      INTO userShiftContextID
      FROM UserShifts us
INNER JOIN Users u
        ON us.userID = u.id
     INNER JOIN Roles r
        ON u.roleID = r.id
     WHERE us.id = NEW.userShiftID;

    SELECT r.contextID
      INTO requestingUserContextID
      FROM Users u
     INNER JOIN Roles r
        ON u.roleID = r.id
     WHERE u.id = NEW.requestingUserID;
	
    SELECT r.contextID
      INTO targetUserContextID
      FROM Users u
     INNER JOIN Roles r
        ON u.roleID = r.id
     WHERE u.id = NEW.targetUserID;
	
    IF userShiftContextID != requestingUserContextID || userShiftContextID != targetUserContextID || requestingUserContextID != targetUserContextID
    THEN
        SIGNAL error_context_id_mismatch;
    END IF;
END;	
//
DELIMITER ;



