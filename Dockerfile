# Development
FROM ubuntu:18.04

# JRE installation and gcc
RUN apt-get update -y && apt-get install -y \
    gcc \
    pkg-config \
    build-essential \
    libsodium-dev \
    libssl-dev \
    libgmp3-dev \
    build-essential \
    libsqlite3-dev \
    libsqlite0 \
    cmake \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    debhelper \
    wget \
    git \
    curl \
    libffi-dev \
    zlib1g-dev \
    nodejs \
    ruby \
    ruby-dev \
    sudo \
    rubygems \
    libzmq5 \
    python3 \
    libtool \
    openjdk-8-jdk \
    maven \
    apt-transport-https \
    libzmq3-dev \
    zip \
    unzip \
    vim

# Install Nodejs 
#RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
#    && apt-get install -y nodejs

# Install Rust
# Install Rust
ARG RUST_VER="1.41.0"
ENV RUST_ARCHIVE=rust-${RUST_VER}-x86_64-unknown-linux-gnu.tar.gz
ENV RUST_DOWNLOAD_URL=https://static.rust-lang.org/dist/$RUST_ARCHIVE

RUN mkdir -p /rust
WORKDIR /rust

RUN curl -fsOSL $RUST_DOWNLOAD_URL \
    && curl -s $RUST_DOWNLOAD_URL.sha256 | sha256sum -c - \
    && tar -C /rust -xzf $RUST_ARCHIVE --strip-components=1 \
    && rm $RUST_ARCHIVE \
    && ./install.sh

RUN cargo install cargo-deb

# fpm for deb packaging of npm
#RUN gem install fpm
RUN gem install rails -v 5.2.0
RUN gem install bundler:1.17.3
#RUN apt-get install rpm -y
RUN gem update --system 3.0.6

# Add sovrin to sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CE7709D068DB5E88 && \
    add-apt-repository "deb https://repo.sovrin.org/sdk/deb xenial master" && \
    add-apt-repository "deb https://repo.sovrin.org/sdk/deb xenial stable" && \
    add-apt-repository 'deb https://repo.sovrin.org/deb xenial master'

#ARG LIBINDY_VER="1.6.7"
#ARG LIBNULL_VER="1.6.7"

RUN apt-get update && apt-get install -y \
    libindy=1.8.1 \
    libnullpay=1.8.1

WORKDIR /

# Copy the main application.
COPY . ./

RUN bundle

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default. Uses 5000 for dokku, but overriden by heroku.yml
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "5000"]
