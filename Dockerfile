FROM ruby:2.3
MAINTAINER BinaryBabel OSS

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /app
WORKDIR /app

VOLUME ["/app/data"]

ENV RAILS_ENV=production RAILS_SERVE_STATIC_FILES=1

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install --deployment --without development test

ADD . /app

RUN ./bin/rake assets:precompile

ENV REFRESH_ENABLED=1

ENTRYPOINT ["./bin/rake"]
CMD ["start"]
