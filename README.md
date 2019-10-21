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

> Note: Creating the .env file didn't seem to work in some instances.  Until the bug is fixed, you may need to manually set the secret/key directly in the Ruby code (currently, registration_helper.rb:30-31)

## Usage
1. When creating an assignment in Canvas, and associating it with the tool, a record in the tool's data is created.  We need to associate the assignment in canvas with the one in the tool, then create a submission.  We can do that using the following commands:

```ruby
a = Assignment.last
a[:tc_id] = 12 # get from Canvas data
a.save
```

2. Create a submission in Canvas and find its id.  Then back in the rails console:
```ruby
a.submissions.create(tc_id: 7)
```

3. Launch the tool from tool from Course Navigation menu in Canvas
4. The submission should show, click the button in the last column
5. Set the score and click "Update Report"