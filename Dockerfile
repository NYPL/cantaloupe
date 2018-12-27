FROM jruby:9.2

# Default Cantaloupe port
EXPOSE 8182

# throw errors if Gemfile has been modified since Gemfile.lock
# RUN bundle config --global frozen 1
RUN mkdir /usr/src/cantaloupe
WORKDIR /usr/src/cantaloupe

# Bundle gems at build time
COPY ./cantaloupe-4.0.2/Gemfile ./
RUN bundle platform
RUN bundle install

# No need to copy app, it's mounted in docker-compose.yml

CMD java -Dcantaloupe.config=./cantaloupe.properties -Xmx2g -jar cantaloupe-4.0.2.war
