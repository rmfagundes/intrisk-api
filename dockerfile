FROM ruby:2.2.3

RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
ADD Gemfile.lock /$APP_HOME/

ENV BUNDLE_PATH=/bundle

RUN bundle config --global --jobs 16 &&\
    bundle install -j16

ADD Rakefile /$APP_HOME/

ADD . $APP_HOME