FROM ruby:2.4.3-slim

ENV RAILS_ROOT=/app
ENV RAILS_ENV=production

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client libproj-dev curl apt-transport-https

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn -y

RUN mkdir -p /app/tmp/pids
WORKDIR /app

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle check || bundle install --without development test -j4
COPY config/puma.rb config/puma.rb
COPY . .

RUN mkdir -p /etc/nginx/conf.d/
COPY ./containers/production/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./containers/production/.env /app/.env
RUN DB_ADAPTER=nulldb RAILS_ENV=production SECRET_KEY_BASE=test bundle exec rails assets:precompile
EXPOSE 3000
