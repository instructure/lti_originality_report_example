FROM ruby:2.7
RUN apt-get update && apt-get install -qq -y --no-install-recommends \
      build-essential nodejs libpq-dev python
ENV APP_HOME='/usr/src/app' RAILS_LOG_TO_STDOUT='true' REDIS_CACHE='true'
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
RUN bundle exec rake RAILS_ENV=production DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname SECRET_TOKEN=dummytoken assets:precompile
VOLUME ["$APP_HOME/public"]
CMD puma -C config/puma.rb
