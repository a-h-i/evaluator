Evaluator
=========
[![Code Climate](https://codeclimate.com/github/ah450/evaluator/badges/gpa.svg)](https://codeclimate.com/github/ah450/evaluator) [![Build Status](https://travis-ci.org/ah450/evaluator.svg?branch=master)](https://travis-ci.org/ah450/evaluator) [![Test Coverage](https://codeclimate.com/github/ah450/evaluator/badges/coverage.svg)](https://codeclimate.com/github/ah450/evaluator/coverage)[![Dependency Status](https://gemnasium.com/ah450/evaluator.svg)](https://gemnasium.com/ah450/evaluator)


Node version `11.6.0`


Ruby version `2.6.1`


Check wiki for additional information.






Install backend app dependencies
================================
`bundle install`

Tests
=====

`bundle exec rake`



Install frontend app
====================
`cd frontend`


`npm install`


`bower install`


Building frontend
=================
All the following commands inside `frontend` directory.





deploy to /srv/www (default) `npm run deploy`


deploy in client/dist directory `npm run dist`






Run development version
=======================
Make sure db is created and migrated.


`bundle exec rails s &`


`cd frontend`


`npm run dev`


Development server is now running on port 8000




JOB Queue
=========
To run the job queue `QUEUE=* rake environment resque:work`



Deployment
==========
Documentation for deployment can be found [here](deployment/README.md)