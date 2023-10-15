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
-- Augments Users with data from Roles and Contexts (via UserRoles)
-- ================================================================================================
CREATE VIEW UsersView
AS
SELECT u.id AS userID,
       u.externalID AS userExternalID,
       u.externalIDText AS userExternalIDText,
       u.firstName AS userFirstName,
       u.lastName AS userLastName,
       u.emailAddress AS userEmailAddress,
       u.supplementaryJSON AS userSupplementaryJSON,

       ur.id AS userRoleID,
       ur.externalID AS userRoleExternalID,
       ur.externalIDText AS userRoleExternalIDText,

       rv.roleID AS roleID,
       rv.roleExternalID AS roleExternalID,
       rv.roleExternalIDText AS roleExternalIDText,
       rv.roleRole AS roleRole,
       rv.roleSupplementaryJSON AS roleSupplementaryJSON,

       rv.contextID AS contextID,
       rv.contextExternalID AS contextExternalID,
       rv.contextExternalIDText AS contextExternalIDText,
       rv.contextName AS contextName,
       rv.contextSupplementaryJSON AS contextSupplementaryJSON
  FROM Users u
 INNER JOIN UserRoles ur
    ON ur.userID = u.id
 INNER JOIN RolesView rv
    ON rv.roleID = ur.roleID;
