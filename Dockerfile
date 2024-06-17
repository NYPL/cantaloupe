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

# Copy libs
COPY lib/* /usr/lib

# Set the working directory
WORKDIR /usr/src/app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy app
COPY app/* .

# Startup command requires libraries on classpath and ruby files in current directory
CMD java -cp /usr/lib/mysql-connector-java-8.0.27.jar:/usr/lib/cantaloupe-5.0.5.jar -Dcantaloupe.config=./cantaloupe.properties -Xmx2g edu.illinois.library.cantaloupe.StandaloneEntry
