FROM ruby:2.4.3-slim

RUN apt-get update -qq && apt-get install -y build-essential firebird-dev

RUN adduser --disabled-password --gecos "" app

RUN mkdir /output /app

ADD . /app

WORKDIR /app

RUN bundle install

RUN apt-get -y autoclean && apt-get -y autoremove && \
  apt-get -y clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ruby run.rb -o /output && chown -R app:app /output
