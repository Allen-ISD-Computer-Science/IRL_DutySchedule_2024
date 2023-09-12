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
-- RolesView
-- Augments Roles with data from Contexts
-- ================================================================================================
CREATE VIEW RolesView
AS
SELECT r.id AS roleID,
       r.externalID AS roleExternalID,
       
       c.id AS contextID,
       c.externalID AS contextExternalID,
       c.name AS contextName
  FROM Roles r
 INNER JOIN Contexts c
    ON r.contextID = c.id;
