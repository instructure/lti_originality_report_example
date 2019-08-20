# Similarity Detection Reference Tool

[![Build Status](https://travis-ci.org/instructure/lti_originality_report_example.svg?branch=master)](https://travis-ci.org/instructure/lti_originality_report_example)
[![Code Climate](https://codeclimate.com/github/instructure/lti_originality_report_example.svg)](https://codeclimate.com/github/instructure/lti_originality_report_example)
[![Dependency Status](https://gemnasium.com/badges/github.com/instructure/lti_originality_report_example.svg)](https://gemnasium.com/github.com/instructure/lti_originality_report_example)

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

A reference tool demonstrating the basic usage of the Canvas plagiarism detection platform. For a simple reference on doing basic LTI 2.1 registration and launches please see the [LTI 2.1 reference tool](https://github.com/instructure/lti2_reference_tool_provider).

## Setup
```
docker-compose build
docker-compose run web rails db:create
docker-compose run web rails db:migrate
```
For local developement a `.env` file should be created at the root directory of the repository and look like this:
```
CANVAS_DEV_KEY=<your developer key id>
CANVAS_DEV_SECRET=<your deveoper key secret>
```
The developer key values in this file should be from the developer key associated with your custom tool consumer profile.
