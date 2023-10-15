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
-- PositionsView
-- Positions supplemented by Contexts, Duties, and Locations data
-- ================================================================================================
CREATE VIEW PositionsView
AS
     SELECT p.id AS positionID,
            p.externalID AS positionExternalID,
	    p.externalIDText AS positionExternalIDText,

	    c.id AS contextID,
	    c.externalID AS contextExternalID,
	    c.externalIDText AS contextExternalIDText,
	    c.name AS contextName,
	    c.supplementaryJSON AS contextSupplementaryJSON,

	    d.id AS dutyID,
	    d.externalID AS dutyExternalID,
	    d.externalIDText AS dutyExternalIDText,
	    d.name AS dutyName,
	    d.description AS dutyDescription,
	    d.supplementaryJSON AS dutySupplementaryJSON,

	    l.id AS locationID,
	    l.externalID AS locationExternalID,
	    l.externalIDText AS locationExternalIDText,
	    l.name AS locationName,
	    l.description AS locationDescription,
	    l.supplementaryJSON AS locationSupplementaryJSON
       FROM Positions p
 INNER JOIN Duties d
         ON p.dutyID = d.id
 INNER JOIN Locations l
         ON p.locationID = l.id
 INNER JOIN Contexts c
         ON d.contextID = c.id
	AND l.contextID = c.id;
 
	    
