FROM ruby
WORKDIR /work
RUN apt-get update && apt-get install -y vim
ADD Gemfile .
ADD Gemfile.lock .
ADD ace-client-ext.gemspec .
ADD VERSION .
RUN bundle install
