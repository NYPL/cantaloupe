FROM openjdk:11

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

WORKDIR /cantaloupe

# Copy Cantaloupe jar
COPY cantaloupe-5.0.5.jar .

# Copy JDBC driver
COPY mysql-connector-java-8.0.27.jar .

# Copy and install gems
# TODO: bundle is not available, how to install gems?
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install

# Copy config
COPY cantaloupe.properties .
COPY delegates.rb .
COPY secrets.rb .

CMD java -cp ./mysql-connector-java-8.0.27.jar:./cantaloupe-5.0.5.jar -Dcantaloupe.config=./cantaloupe.properties -Xmx2g edu.illinois.library.cantaloupe.StandaloneEntry
