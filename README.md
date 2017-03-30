# Similarity Detection Reference Tool
A reference tool demonstrating the basic usage of the Canvas plagiarism detection platform. For a simple reference on doing basic LTI 2.1 registration and launches please see the [LTI 2.1 reference tool](https://github.com/instructure/lti2_reference_tool_provider).

## Setup
```
docker-compose up --build
docker-compose exec web rails db:reset
docker-compose exec web rails db:migrate
```
