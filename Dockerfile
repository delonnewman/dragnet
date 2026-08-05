# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION="3.4.9"
ARG TARGETPLATFORM=linux/amd64
FROM ruby:$RUBY_VERSION-slim AS base

LABEL org.opencontainers.image.description="A programable system for data collection and analysis."
LABEL org.opencontainers.image.source="https://github.com/delonnewman/dragnet"
LABEL org.opencontainers.image.licenses=GPL2

ARG BUNDLE_WITHOUT="development:test"
ARG RAILS_ENV="production"
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    TZ=UTC \
    RAILS_ENV=$RAILS_ENV \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_WITHOUT=$BUNDLE_WITHOUT

# Rails app lives here
WORKDIR /rails

# Update gems and bundler
RUN gem update --system --no-document && \
    gem install -N bundler

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock .
RUN bundle install -j$(nproc)

# Copy application code
COPY . .

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN --mount=type=secret,id=master_key,env=RAILS_MASTER_KEY \
    ./bin/rails assets:precompile

# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Run and own the application files as a non-root user for security
ARG UID=1000 \
    GID=1000
RUN groupadd -f -g $GID rails && \
    useradd -u $UID -g $GID rails
USER rails:rails

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=rails:rails /rails /rails

# Deployment options
ENV RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true" \
    RUBY_YJIT_ENABLE="1"
    # LD_PRELOAD="/usr/lib/aarch64-linux-gnu/libjemalloc.so.2" \
    # MALLOC_CONF="dirty_decay_ms:1000,narenas:2,background_thread:true"

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
