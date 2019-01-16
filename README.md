# What is this?

NYPL's implementation of the Cantaloupe [IIIF image server](https://medusa-project.github.io/cantaloupe/).
It is configured to read source images from S3.

## Installing

This uses Docker to locally to make it as easy as possible for developers to install.

1.  Clone this git repository.
2.  `cp .env.example .env` (and fill in .env with credentials)
3.  `docker-compose build`

## Running

1.  `docker-compose up`

## Using

This branch looks for source images in the S3 bucket named set by the `SOURCE_S3_BUCKET_NAME`
environment variable. The key and secret can be found in parameter store,
see [.env.example](./.env.example) for the parameter store key.

### Caching

Locally, source and derivative images are cached in `./cantaloupe-4.0.2/cache`
which is mounted into the container, thanks to [docker-compose.yml](./docker-compose.yml).

In the container, that is the directory `/usr/src/cantaloupe/cache` in both production and
locally.

#### Clustered Caching

Our first, naive implementation will have each container have its own cache
but I could see us mounting the cache directory from the host machine into
the multiple containers so they can share it.

## Git Workflow

Our branches (in order or stability are):

| Branch     | Environment | AWS Account      | Link To Application |
|:-----------|:------------|:-----------------|:--------------------|
| master     | none        | NA               | NA                  |
| qa         | qa          | nypl-digital-dev | ???                 |
| production | production  | nypl-digital-dev | ???                 |

1. Feature branches are cut from `master`.
2. Once the feature branch is ready to be merged, file a pull request of the branch _into_ master.
3. Branches are "promoted" by merging from less stable to more. (master -> qa -> production )

## Deployment

We use Travis for continuous deployment.
Merging to certain branches automatically deploys to the environment associated to
that branch.

| Merge from | Into         | Deploys to...  |
|:-----------|:-------------|:---------------|
| `master`   | `qa`         | qa env         |
| `qa`       | `production` | production env |

For insight into how CD works look at [.travis.yml](./.travis.yml) and the
[provisioning/travis_ci_and_cd](./provisioning/travis_ci_and_cd) directory.
The approach is inspired by [this blog post](https://dev.mikamai.com/2016/05/17/continuous-delivery-with-travis-and-ecs/) ([google cached version](https://webcache.googleusercontent.com/search?q=cache:NodZ-GZnk6YJ:https://dev.mikamai.com/2016/05/17/continuous-delivery-with-travis-and-ecs/+&cd=1&hl=en&ct=clnk&gl=us&client=firefox-b-1-ab)).
