FROM ruby:2.3.1
ENV LANG C.UTF-8

RUN /bin/cp -f /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
    && apt-get update -qq \
    && apt-get install -y build-essential libmysql++-dev nodejs git \
    && npm install -g gulp-cli bower eslint babel-eslint

ENV APP_HOME /var/www/html
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile $APP_HOME/Gemfile
ADD Gemfile.lock $APP_HOME/Gemfile.lock

ENV BUNDLE_DISABLE_SHARED_GEMS 1
RUN cd $APP_HOME \
  && bundle install

ADD . $APP_HOME
CMD ["bundle", "exec", "rails", "db:migrate"]
