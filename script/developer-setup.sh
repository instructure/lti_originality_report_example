#!/bin/sh

# Sets up the project for development using Docker and docker-compose.

# Use the example override file.
if [ -f "docker-compose.override.yml"]; then
  echo "An existing docker-compose override files exists, skipping copying the default file."
else
  echo "Using example docker-compose override as override"
  cp docker-compose.override.example.yml docker-compose.override.yml
fi

# Build and migrate everything
docker-compose build
docker-compose run web rails db:create
docker-compose run web rails db:migrate