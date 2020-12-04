FROM jruby:9.2 as production

ENV CANTALOUPE_VERSION=4.1.7

EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
RUN apt-get update -qy && apt-get dist-upgrade -qy && \
    apt-get install -qy --no-install-recommends curl imagemagick \
    libopenjp2-tools ffmpeg unzip default-jre-headless && \
    apt-get -qqy autoremove && apt-get -qqy autoclean

# Run non privileged
RUN adduser --system cantaloupe

# Get and unpack Cantaloupe release archive
RUN curl --silent --fail -OL https://github.com/medusa-project/cantaloupe/releases/download/v$CANTALOUPE_VERSION/Cantaloupe-$CANTALOUPE_VERSION.zip \
    && unzip Cantaloupe-$CANTALOUPE_VERSION.zip \
    && ln -s cantaloupe-$CANTALOUPE_VERSION cantaloupe \
    && rm Cantaloupe-$CANTALOUPE_VERSION.zip \
    && mkdir -p /var/log/cantaloupe /var/cache/cantaloupe \
    && chown -R cantaloupe /cantaloupe /var/log/cantaloupe /var/cache/cantaloupe \
    && cp -rs /cantaloupe/deps/Linux-x86-64/* /usr/

COPY Gemfile /cantaloupe/Gemfile
COPY cantaloupe.properties /cantaloupe/cantaloupe.properties
COPY secrets.rb /cantaloupe/secrets.rb
COPY delegates.rb /cantaloupe/delegates.rb
RUN touch /cantaloupe/Gemfile.lock \
    && chmod a+w /cantaloupe/Gemfile.lock

WORKDIR /cantaloupe
RUN bundle platform && bundle install

USER cantaloupe

CMD ["sh", "-c", "java -Dcantaloupe.config=/cantaloupe/cantaloupe.properties -Xmx2g -jar /cantaloupe/cantaloupe-$CANTALOUPE_VERSION.war"]

# FROM production AS development

