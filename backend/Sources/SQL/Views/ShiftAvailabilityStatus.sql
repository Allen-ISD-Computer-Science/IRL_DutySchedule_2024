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
-- ShiftsAvailabilityStatus
-- Augments Shifts with data from UserShifts to indicate if a given shift is available or
-- fulfilled
-- ================================================================================================
CREATE VIEW ShiftAvailabilityStatus
AS 
SELECT s.id AS shiftID,
       s.externalID AS shiftExternalID,
       s.externalIDText AS shiftExternalIDText,
       s.dayID AS shiftDayID,
       s.positionID AS shiftPositionID,
       s.startTime AS shiftStartTime,
       s.endTime AS shiftEndTime,
       s.supplementaryJSON AS shiftSupplemnetaryJSON,

       us.id AS userShiftID,
       us.externalID AS userShiftExternalID,
       us.externalIDText AS userShiftExternalIDText,
       us.userID AS userShiftUserID,
       us.supplementaryJSON AS userShiftSupplementaryJSON,

       CASE
           WHEN us.id IS NULL THEN 'Available' 
           ELSE 'Fulfilled' 
       END AS fulfilledStatus
  FROM Shifts s 
  LEFT OUTER JOIN UserShifts us 
    ON s.id = us.shiftID;
