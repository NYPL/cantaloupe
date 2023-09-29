# What is this?

NYPL's implementation of the Cantaloupe [IIIF image server](https://medusa-project.github.io/cantaloupe/).
It is configured to read source images from S3.

## Installing

This uses Docker to locally to make it as easy as possible for developers to install.

1.  `cp .env.example .env` (and fill in .env with credentials)
2.  Optional: To work locally on the shim, edit `nginx-configs/image_server_to_iiif.js` and comment out line 44 and comment in line 47. (NB: Make sure to revert these changes for deployment.)
3.  `docker-compose build`
4.  `docker-compose up`
4.  Test in a browser: http://localhost:8182/iiif/2/53926/full/full/0/default.jpg
5.  Test shim in a browser: http://localhost:8080/index.php?id=53926&t=f

## Using

This branch looks for source images in the `./images` directory, which is mounted in the container at `/var/www/images.nypl.org`.

Source and derivative images are cached in `./cache`, which is mounted into the container at `/ifs/prod/iiif-imagecache`.

## Git Workflow

Our branches (in order or stability are):

| Branch     | Environment | AWS Account      | Example link                                      |
|:-----------|:------------|:-----------------|:--------------------------------------------------|
| develop    | none        | NA               | NA                                                |
| qa         | qa          | nypl-digital-dev | https://qa-iiif.nypl.org/index.php?id=1590363&t=w |
| production | production  | nypl-digital-dev | https://iiif.nypl.org/index.php?id=1590363&t=w    |

1. Feature branches are cut from `develop`.
2. Once the feature branch is ready to be merged, file a pull request of the branch _into_ develop.
3. Branches are "promoted" by merging from less stable to more. (develop -> qa -> production )
4. Always make sure to revert to deployment settings in the secrets.rb before commiting changes to deploy.

## Deployment

We use Bamboo for deployments. The canteloupe.properties.dev config file is applied for qa deployments, and the canteloupe.properties.prod config file is applied for production deployments. The previous properties file on the server is moved to canteloupe.properties.old.

The deployed servers do not run in docker, so the deploy scripts (configured in bamboo) are responsible for repeating the steps in the dockerfile to configure and deploy the new server and restart the service. Each server instance is updated in sequence prevent service downtime.

| Job ...                                             | Deploys branch ... | Deploys to ...   | Shim ...           |
|:----------------------------------------------------|:-------------------|:-----------------|:-------------------|
| `https://bamboo02.nypl.org/browse/DAMS-DCRNI`       | `qa`               | qa-iiif.nypl.org | iiif-qa.nypl.org   |
| `https://bamboo02.nypl.org/browse/DAMS-DCRNP`       | `production`       | iiif.nypl.org    | iiif-prod.nypl.org |
