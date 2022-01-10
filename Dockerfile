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

# Copy Cantaloupe war
COPY cantaloupe-4.1.9.war .

# Copy JDBC driver
COPY mysql-connector-java-8.0.27.jar .

# Copy config
COPY cantaloupe.properties .
COPY delegates.rb .
COPY secrets.rb .

CMD java -cp ./mysql-connector-java-8.0.27.jar:./cantaloupe-4.1.9.war -Dcantaloupe.config=./cantaloupe.properties -Xmx2g edu.illinois.library.cantaloupe.StandaloneEntry
