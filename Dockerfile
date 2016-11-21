FROM ruby:2.3
MAINTAINER BinaryBabel OSS

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /app
WORKDIR /app

VOLUME ["/app/data"]

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install

ADD . /app

ENV RAILS_ENV production

RUN bundle exec rake assets:precompile

ENV REFRESH_ENABLED 1

CMD ["bundle", "exec", "rake", "start"]
