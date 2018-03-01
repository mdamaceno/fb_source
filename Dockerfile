FROM ruby:2.4

RUN apt-get update -qq && apt-get install -y build-essential firebird2.5-dev

RUN mkdir /app
RUN mkdir /output

WORKDIR /app

ADD Gemfile /app/Gemfile

ADD Gemfile.lock /app/Gemfile.lock

RUN bundle install

RUN chmod 775 -R /output

ADD . /app

ENV OUTPUT_PATH=/output
VOLUME /output

CMD ruby run.rb
