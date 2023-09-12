#!/bin/bash
# Copyright (C) 2023 Ryan Hallock, Muqadam Sabir, David Ben-Yaakov
# This program was developed using codermerlin.academy resources.
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see https://www.gnu.org/licenses/.

# Stop on error and undefined variables
set -eu

# Assumes mysql starts using configuration file with credentials
cat SelectDatabase.sql \
    \
    ../Tables/Contexts.sql \
    ../Tables/Roles.sql \
    ../Tables/Users.sql \
    ../Tables/Duties.sql \
    ../Tables/Locations.sql \
    ../Tables/Positions.sql \
    ../Tables/Days.sql \
    ../Tables/Shifts.sql \
    ../Tables/UserShifts.sql \
    ../Tables/UserShiftChangeRequests.sql \
    ../Tables/Availability.sql \
    ../Tables/UserAvailability.sql \
    ../Views/RolesView.sql | mysql

