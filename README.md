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


## Installing in Canvas
1. Create a developer key in Canvas. The "Vendor code" should be set to `Instructure.com`
2. Create a .env file in the lti_originality_report_example project with the following lines:
```
CANVAS_DEV_KEY=<your developer key id>
CANVAS_DEV_SECRET=<your deveoper key secret>
```
3. Create a Tool Comsumer Profile in Canvas via the Rails console:
```
key = DeveloperKey.find(<your developer key id>)
Lti::ToolConsumerProfile.create!(
    services: Lti::ToolConsumerProfile::RESTRICTED_SERVICES,
    capabilities: Lti::ToolConsumerProfile::RESTRICTED_CAPABILITIES,
    developer_key: key
)
```
4. Navigate to a Canvas course or account and go to settings > +App and Change the configuration type to "By LTI 2 Registration URL."
5. Paste in the tools registration URL (found on the tool's home page) to install the tool in Canvas.
