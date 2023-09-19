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
-- UsersView
-- Augments Users with data from Roles and Contexts
-- ================================================================================================
CREATE VIEW UsersView
AS
SELECT u.id AS userID,
       u.firstName AS userFirstName,
       u.lastName AS userLastName,
       u.emailAddress AS userEmailAddress,

       rv.roleID AS roleID,
       rv.rolesExternalID AS roleExternalID,

       rv.contextID AS contextID,
       rv.externalID AS contextExternalID,
       rv.name AS contextName
  FROM Users u
 INNER JOIN RolesView rv
    ON u.roleId = rv.id;
