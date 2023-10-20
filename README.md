# Building on CoderMerlin
* Required environment variables
  * PUBLIC_URL
  * REACT_APP_USER 
* Execute 'build' from the root of the project
  * This will build the backend and the frontend
  * The frontend will be copied to Vapor for serving

# Running on CoderMerlin
* Required enviornment variables
  * MYSQL_HOSTNAME
  * MYSQL_PORT
  * MYSQL_DATABASE_NAME
  * MYSQL_USERNAME
  * MYSQL_PASSWORD
* Execute 'run' from the root of the project

# Rebuilding the Frontend
If necessary to clear the npm cache:
* `npm cache clean --force`

In case of emergency:
* delete the node modules folder by running `rm -rf node_modules`
* delete package.lock.json file by running `rm -f package-lock.json`
* clean up the NPM cache by running `npm cache clean --force`
* install all packages again by running `npm install`


