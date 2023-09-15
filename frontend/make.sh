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

# Some limits will need to be increased in order to successfully build:
# * open files - execute: `ulimit -n 8192`
# * user processes - execute: `ulimit -u 256`
ulimit -n 8192
ulimit -u 256

# Build
npm install
