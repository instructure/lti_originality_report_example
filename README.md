# Similarity Detection Reference Tool
[![Build Status](https://travis-ci.org/instructure/lti_originality_report_example.svg?branch=master)](https://travis-ci.org/instructure/lti_originality_report_example)
[![Code Climate](https://codeclimate.com/github/instructure/lti_originality_report_example.svg)](https://codeclimate.com/github/instructure/lti_originality_report_example)
[![Dependency Status](https://gemnasium.com/badges/github.com/instructure/lti_originality_report_example.svg)](https://gemnasium.com/github.com/instructure/lti_originality_report_example)

A reference tool demonstrating the basic usage of the Canvas plagiarism detection platform. For a simple reference on doing basic LTI 2.1 registration and launches please see the [LTI 2.1 reference tool](https://github.com/instructure/lti2_reference_tool_provider).

## Setup
```
docker-compose up --build
docker-compose exec web rails db:reset
docker-compose exec web rails db:migrate
```
