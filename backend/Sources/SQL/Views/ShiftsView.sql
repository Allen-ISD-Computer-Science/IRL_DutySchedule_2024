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
-- ShiftsView
-- Augments Shifts with data from Contexts, Shifts, Days, and Positions
-- ================================================================================================
CREATE VIEW ShiftsView
AS
SELECT s.id AS shiftID,
       s.externalID AS shiftExternalID,
       s.externalIDText AS shiftExternalIDText,
       s.startTime AS shiftStartTime,
       s.endTime AS shiftEndTime,
       s.supplementaryJSON AS shiftSupplementaryJSON,

       pv.contextID,
       pv.contextExternalID,
       pv.contextExternalIDText,
       pv.contextName,
       pv.contextSupplementaryJSON,

       d.id AS dayID,
       d.externalID AS dayExternalID,
       d.externalIDText AS dayExternalIDText,
       d.day AS dayDay,
       d.supplementaryJSON AS daySupplementaryJSON,
       d.dayOfWeek AS dayDayOfWeek,

       pv.positionID,
       pv.positionExternalID,
       pv.positionExternalIDText,

       pv.dutyID,
       pv.dutyExternalID,
       pv.dutyExternalIDText,
       pv.dutyName,
       pv.dutyDescription,
       pv.dutySupplementaryJSON,

       pv.locationID,
       pv.locationExternalID,
       pv.locationName,
       pv.locationDescription,
       pv.locationSupplementaryJSON

  FROM Shifts s
 INNER JOIN Days d
    ON s.dayID = d.id
 INNER JOIN PositionsView pv
    ON s.positionID = pv.positionID;

   
      
