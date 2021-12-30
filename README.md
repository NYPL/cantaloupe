# What is this?

NYPL's implementation of the Cantaloupe [IIIF image server](https://medusa-project.github.io/cantaloupe/).
It is configured to read source images from S3.

## Installing

We've temporarily stopped using Docker for local setup. In the meantime, the following more complicated steps should work to get you up and running locally. 

1.  Clone this git repository.
2.  `cp cantaloupe-local.properties.sample cantaloupe-local.properties`
3.  In this file, edit the path for `FilesystemCache.pathname` to wherever you want your local cache to live. 
4.  Might need to also edit the path for `GraphicsMagickProcessor.path_to_binaries` to wherever you find your GM bin. (Mine is at `/usr/local/Cellar/graphicsmagick/1.3.37/bin` right now.)
5. If not already created, create a local mysql database and import the small sql file found `db/filestore-sample-db.sql`. Make note of user / password and database host name for use in the next step. 
6. In the `secrets.rb` file, comment out the development set of configs and un-comment-out the set for local development. Edit the values as appropriate. 

## Running

If all of that went well, you should be able to run the server. 

1. `java -cp ./mysql-connector-java-8.0.27.jar:./cantaloupe-4.1.9.war -Dcantaloupe.config=./cantaloupe-local.properties -Xmx2g edu.illinois.library.cantaloupe.StandaloneEntry`

You should be able to see a response with a call like `http://localhost:8182/iiif/2/anything/full/full/0/default.jpg`. 

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
4. Always make sure to revert to deployment settings in the secrets.rb before commiting changes to deploy. 

## Deployment

We use Bamboo for deployments. 

| Job ...                                             | Deploys branch ... | Deploys to ...     |
|:----------------------------------------------------|:-------------------|:-------------------|
| `https://bamboo02.nypl.org/browse/DAMS-DCRNI`       | `qa`               | dev-iiif.nypl.org  |
| `https://bamboo02.nypl.org/browse/DAMS-DCRNP`       | `production`       | iiif-prod.nypl.org |
