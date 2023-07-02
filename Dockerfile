FROM ruby:3.2.2
RUN apt-get update && \
  apt-get -y install npm locales && \
  npm i -g n && n 18.16.0 && \
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
ENV LANG=en_US.utf8
COPY ["Gemfile", "Gemfile.lock", "/app/"]
WORKDIR /app
RUN bundle config without development:test && bundle
COPY . /app
ENV RAILS_ENV=production
RUN SECRET_KEY_BASE=00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 \
  bin/rails assets:precompile
RUN mkdir -p /app/tmp/pids /app/tmp/sockets
CMD bundle exec puma
