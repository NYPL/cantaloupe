FROM jruby:9.4-jre21

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg2 \
    ca-certificates \
    lsb-release \
    ubuntu-keyring \
    graphicsmagick \
    imagemagick \
    ffmpeg \
    maven \
    libopenjp2-tools \
    redis-server \
    gettext \
  && rm -rf /var/lib/apt/lists/*

# The following adds the offical nginx repository to install nginx and nginx-module-njs. 
# Taken from https://nginx.org/en/linux_packages.html#Ubuntu

# Fetch the official nginx signing key
RUN curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
| tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

# Set up the apt repository for mainline nginx packages
RUN echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
  http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" \
    | tee /etc/apt/sources.list.d/nginx.list

# Set up repository pinning to prefer nxing packages over distribution-provided ones
RUN echo "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
| tee /etc/apt/preferences.d/99nginx

# Install nginx and nginx-module-njs
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    nginx-module-njs \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/images.nypl.org

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

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx-configs/nginx.conf /etc/nginx/nginx.conf
COPY nginx-configs/shim_conf.conf /etc/nginx/conf.d/
COPY nginx-configs/image_server_to_iiif.js /etc/nginx/conf.d/


# Start the Java application and Nginx
CMD service nginx start && \
  java -cp ./mysql-connector-java-8.0.27.jar:./cantaloupe-5.0.5.jar -Dcantaloupe.config=./cantaloupe.properties -Xmx2g edu.illinois.library.cantaloupe.StandaloneEntry
