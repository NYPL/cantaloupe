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

This branch looks for source images in a chosen local file directory. 

### Caching

Locally, source and derivative images are cached in `./cantaloupe/cache`
which is mounted into the container, thanks to [docker-compose.yml](./docker-compose.yml).

In the container, that is the directory `/usr/src/cantaloupe/cache` in both production and
locally.

#### Clustered Caching

Our first, naive implementation will have each container have its own cache
but I could see us mounting the cache directory from the host machine into
the multiple containers so they can share it.

## Git Workflow

Our branches (in order or stability are):

| Branch     | Environment | AWS Account      | Example link                                         |  
|:-----------|:------------|:-----------------|:-----------------------------------------------------|
| main       | none        | NA               | NA                                                   |
| develop    | none        | NA               | NA                                                   |
| qa         | qa          | nypl-digital-dev | https://dev-iiif.nypl.org/index.php?id=1590363&t=w   |
| production | production  | nypl-digital-dev | https://iiif-prod.nypl.org/index.php?id=1590363&t=w  |

1. Feature branches are cut from `develop`.
2. Once the feature branch is ready to be merged, file a pull request of the branch _into_ develop.
3. Branches are "promoted" by merging from less stable to more. (develop -> qa -> production )

## Deployment

We use Bamboo for deployments. 

| Job ...                                             | Deploys branch ... | Deploys to ...     |
|:----------------------------------------------------|:-------------------|:-------------------|
| `https://bamboo02.nypl.org/browse/DAMS-DCRNI`       | `qa`               | dev-iiif.nypl.org  |
| `https://bamboo02.nypl.org/browse/DAMS-DCRNP`       | `production`       | iiif-prod.nypl.org |
