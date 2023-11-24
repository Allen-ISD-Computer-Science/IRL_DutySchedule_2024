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
-- UsersWithMatchingAvailabilityForShift
-- Provides list of users with availability matching a particular shift without regard
-- to whether or not they've enrolled for a different shift
-- ================================================================================================
CREATE VIEW UsersWithMatchingAvailabilityForShift
AS 
SELECT sv.shiftID,
       sv.shiftExternalID,
       sv.shiftExternalIDText,
       sv.shiftStartTime,
       sv.shiftEndTime,
       sv.shiftSupplementaryJSON,
       sv.contextID,
       sv.contextExternalID,
       sv.contextExternalIDText,
       sv.contextName,
       sv.contextSupplementaryJSON,
       sv.dayID,
       sv.dayExternalID,
       sv.dayExternalIDText,
       sv.dayDay,
       sv.daySupplementaryJSON,
       sv.dayDayOfWeek,
       sv.positionID,
       sv.positionExternalID,
       sv.positionExternalIDText,
       sv.dutyID,
       sv.dutyExternalID,
       sv.dutyExternalIDText,
       sv.dutyName,
       sv.dutyDescription,
       sv.dutySupplementaryJSON,
       sv.locationID,
       sv.locationExternalID,
       sv.locationExternalIDText,
       sv.locationName,
       sv.locationDescription,
       sv.locationSupplementaryJSON,
       
       a.id AS availabilityID,
       a.externalID AS availabilityExternalID,
       a.externalIDText AS availabilityExternalIDText,
       a.supplementaryJSON AS availabilitySupplementaryJSON,
       a.startTime AS availabilityStartTime,
       a.endTime AS availabilityEndTime,
       
       u.id AS userID,
       u.externalID AS userExternalID,
       u.externalIDText AS userExternalIDText,
       u.firstName AS userFirstName,
       u.lastName AS userLastName,
       u.emailAddress AS userEmailAddress,
       u.supplementaryJSON AS userSupplementaryJSON
       
       
  FROM ShiftsView sv
 INNER JOIN Availability a
    ON sv.contextID = a.contextID
   AND sv.dayID = a.dayID
   AND sv.shiftStartTime <= a.startTime
   AND sv.shiftEndTime >= a.endTime
 INNER JOIN UserAvailability ua 
    ON a.id = ua.availabilityID
 INNER JOIN Users u 
    ON ua.userID = u.id; 
