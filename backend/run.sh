#!/bin/bash
# Script for building on CoderMerlin
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
set -eu

# Ensure front-end has been built before attempting to run
if [ ! -d "Public/static/" ]
then
    echo "WARN: Frontend has not yet been built."
    echo "      Build front-end before attempting to run by executing"
    echo "      'run' from the root directory."
    exit 1
fi

# Run
makeSwift --mode=run "$@"
