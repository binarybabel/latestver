FROM ruby:2.5
MAINTAINER BinaryBabel OSS

RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - \
    && apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app

VOLUME ["/app/data"]

EXPOSE 3333/tcp

ENV RAILS_ENV=production RAILS_SERVE_STATIC_FILES=1

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install --deployment --without development test

ADD .bowerrc /app/.bowerrc
ADD bower.json /app/bower.json
RUN npm install -g bower \
    && bower --allow-root install

ADD . /app

RUN ./bin/rake assets:precompile

ENV REFRESH_ENABLED=1

ENTRYPOINT ["./bin/rake"]
CMD ["start"]
