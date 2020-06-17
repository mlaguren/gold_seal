FROM alpine:3.10

LABEL maintainer="melvin@laguren.net"
LABEL version="0.1.0"
LABEL image_name="Gold Seal API"
LABEL os="Alpine 3.10"
LABEL ruby_version="2.5.8p224"
LABEL bundler="1.17.2"

RUN apk update
RUN apk add ruby=2.5.8-r0
RUN apk add ruby-dev make gcc libc-dev g++ ruby-etc
RUN gem install bundler -v 2.1.4 --no-ri --no-rdoc

RUN mkdir /ui
WORKDIR /ui
COPY . .

RUN bundle install

EXPOSE 8081

CMD ["bundle", "exec", "ruby", "ui.rb"]