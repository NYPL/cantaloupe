FROM jruby:9.4-jre17

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    graphicsmagick \
    imagemagick \
    ffmpeg \
    maven \
    libopenjp2-tools \
    redis-server \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

# Copy Cantaloupe jar
COPY cantaloupe-5.0.5.jar .

# Copy JDBC driver
COPY mysql-connector-java-8.0.27.jar .

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy config
COPY cantaloupe.properties .
COPY delegates.rb .
COPY secrets.rb .

CMD java -cp ./mysql-connector-java-8.0.27.jar:./cantaloupe-5.0.5.jar -Dcantaloupe.config=./cantaloupe.properties -Xmx2g edu.illinois.library.cantaloupe.StandaloneEntry
