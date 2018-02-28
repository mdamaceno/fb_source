FROM ruby:2.4.1-slim

ADD Gemfile /app/
ADD Gemfile.lock /app/

RUN apt-get update && apt-get install -y build-essential

RUN gem install bundler --no-ri --no-rdoc && \
    cd /app && bundle install --without development test

ADD . /app
RUN chown -R nobody:nogroup /app
USER nobody

ENV RACK_ENV production

WORKDIR /app
