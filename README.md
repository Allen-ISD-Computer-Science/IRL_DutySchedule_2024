# Building on CoderMerlin
Some limits will need to be increased in order to successfully build:
* open files - execute: `ulimit -n 8192`
* user processes - execute: `ulimit -u 256`

If necessary to clear the npm cache:
* `npm cache clean --force`

In case of emergency:
* delete the node modules folder by running `rm -rf node_modules`
* delete package.lock.json file by running `rm -f package-lock.json`
* clean up the NPM cache by running `npm cache clean --force`
* install all packages again by running `npm install`

# Running on CoderMerlin
Steps required to run the application on CoderMerlin:
* in the frontend/ directory - execute: `run`
* in the backend/ directory - execute: `run`
