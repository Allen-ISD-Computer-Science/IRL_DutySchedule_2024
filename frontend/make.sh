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

# We check for undefined variables below. After that, we'll enable -u
set -e

# Some limits will need to be increased in order to successfully build:
ulimit -n 8192
ulimit -u 256
ulimit -v 67108864
ulimit -t 1200

# Required build configuration environment variables
# Be sure not to overwrite existing variables set outside of this script
if [ -z "$PUBLIC_URL" ]
then
    echo "WARN: \$PUBLIC_URL is not defined. Setting default to '/vapor/$USER'"
    export PUBLIC_URL="/vapor/$USER"
else
    echo "\$PUBLIC_URL=$PUBLIC_URL"
fi

if [ -z "$REACT_APP_USER" ]
then
    echo "WARN: \$REACT_APP_USER is not defined. Setting default to '$USER'"
    export REACT_APP_USER=$USER
else
    echo "\$REACT_APP_USER=$REACT_APP_USER"
fi

# Going foward, halt on undefiend variables
set -u

# Build
npm install
npm run build

# Moving build files to Vapor
echo "Moving index.html from the build folder to ../backend/Resources/Views"
echo "Moving files from the build folder to ../backend/Public"
staticFolder="../backend/Public/static"
viewFolder="../backend/Resources/Views"

if [ -d "$staticFolder" ]; then
    echo "Deleting existing static directory..."
    rm -r "$staticFolder"
fi

if [ ! -d "$viewFolder" ]; then
    echo "Creating view folder..."
    mkdir -p $viewFolder
fi

mv -f build/index.html ../backend/Resources/Views
mv -f build/* ../backend/Public

echo "File move completed."
