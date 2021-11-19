FROM openjdk:11

# Install various dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        graphicsmagick \
        imagemagick \
		ffmpeg \
		maven \
		libopenjp2-tools \
		redis-server \
  && rm -rf /var/lib/apt/lists/*

# Install TurboJpegProcessor dependencies
RUN mkdir -p /opt/libjpeg-turbo/lib
COPY cantaloupe/docker/test/image_files/libjpeg-turbo/lib64 /opt/libjpeg-turbo/lib

# Install KakaduNativeProcessor & KakaduDemoProcessor dependencies
COPY cantaloupe/dist/deps/Linux-x86-64/bin/* /usr/bin/
COPY cantaloupe/dist/deps/Linux-x86-64/lib/* /usr/lib/

# A non-root user is needed for some FilesystemSourceTest tests to work.
ARG user=cantaloupe
ARG home=/home/$user
RUN adduser --home $home $user
RUN chown -R $user $home
USER $user
WORKDIR $home

# Install application dependencies
COPY ./cantaloupe/pom.xml pom.xml
RUN mvn dependency:resolve

# Install Minio S3 server for S3SourceTest and S3CacheTest
ARG s3=$home/s3
RUN mkdir -p $s3/.minio.sys/config $s3/test.cantaloupe.library.illinois.edu
COPY cantaloupe/docker/test/image_files/minio_config.json $s3/.minio.sys/config/config.json
RUN curl -O https://dl.minio.io/server/minio/release/linux-amd64/minio
RUN chmod +x minio

# Copy config
COPY --chown=cantaloupe cantaloupe.properties cantaloupe.properties

# Copy cantaloupe source code
COPY --chown=cantaloupe ./cantaloupe/src src

# Compile Cantaloupe
RUN mvn clean compile

CMD mvn exec:java -Dcantaloupe.config=./cantaloupe.properties
