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


## Using

This branch looks for source images in the S3 bucket named `cantaloupe-poc` in
the `nypl-sandbox` account. The key and secret can be found in parameter store,
see [.env.example](./.env.example) for the parameter store key.

Some URLs that will work once everything is configured:

```
http://localhost:8182/iiif/2/beVaDe5KTSiN_AhyEDA73gj/full/full/0/default.jpg
http://localhost:8182/iiif/2/nypl.digitalcollections.64b4a3c1-7a8b-19e1-e040-e00a180640e1.001.g.jpg/full/full/0/default.jpg
http://localhost:8182/iiif/2/nypl.digitalcollections.a7c8a740-d292-012f-c0e3-58d385a7b928.jpg/full/full/0/default.jpg
```
