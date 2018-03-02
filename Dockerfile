FROM ruby:2.4

RUN apt-get update -qq && apt-get install -y build-essential firebird2.5-dev

RUN adduser --disabled-password --gecos "" app

USER app

WORKDIR /home/app

ADD Gemfile /home/app/Gemfile

ADD Gemfile.lock /home/app/Gemfile.lock

RUN bundle install

ADD . /home/app

RUN mkdir /home/app/output

ENV OUTPUT_PATH=/home/app/output

USER root

RUN chmod 777 -R /home/app/output

RUN apt-get -y autoclean && apt-get -y autoremove && \
  apt-get -y clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN chown -R app:app /home/app

USER app

WORKDIR /home/app

VOLUME /home/app/output

CMD ruby run.rb
