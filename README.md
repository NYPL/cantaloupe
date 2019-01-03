# What is this?

A proof-of-concept implementation of the Cantaloupe [IIIF image server](https://medusa-project.github.io/cantaloupe/) suited for NYPL.

It is designed to work the way our image server would. (Connect to a DB to get paths on disk).

## Installing

This uses Docker to locally to make it as easy as possible for developers
to install. In production, I don't think it would be run via Docker.

1.  Clone this git repository.
2.  `cp .env.example .env` (and fill in .env with credentials)
3.  `docker-compose build`

## Running

1.  `docker-compose up`
