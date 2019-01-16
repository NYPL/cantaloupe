FROM jruby:9.2 as production

# Default Cantaloupe port
EXPOSE 8182

# throw errors if Gemfile has been modified since Gemfile.lock
# RUN bundle config --global frozen 1
RUN mkdir /usr/src/cantaloupe
WORKDIR /usr/src/cantaloupe

# Bundle gems at build time
COPY ./cantaloupe-4.0.2 /usr/src/cantaloupe
RUN bundle platform
RUN bundle install

CMD java -Dcantaloupe.config=./cantaloupe.properties -Xmx2g -jar cantaloupe-4.0.2.war

FROM production AS development

# In development mode it will be mounted (thanks to docker-compose.yml)
run rm -rf /usr/src/cantaloupe/*
