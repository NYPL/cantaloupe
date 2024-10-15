# What is this?

NYPL's implementation of the Cantaloupe [IIIF image server](https://medusa-project.github.io/cantaloupe/).
It is configured to read source images from S3.

## Building

You will rarely need to build the underlying cantaloupe project from source. This will only be necessary when a version upgrade is being undertaken or code changes to the source are necessary. NYPL is maintaining a forked version of https://github.com/cantaloupe-project/cantaloupe that lives at https://github.com/NYPL/cantaloupe-project. This forked repository is included in the current project as a submodule in /cantaloupe-project.

### Building on a Mac

* v5.0.5 (the currently used base version) is built using a Java 11 runtime. To install this locally, use `brew install openjdk@11`
* Once Java 11 is installed, you'll want to set it as the default. Find the installation directory with `brew --prefix openjdk@11`
* You may need to symlink the new installation with `sudo ln -sfn <path_to_installation_directory>/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk`
* Open your shell config file (for a bash shell, this'll be `~/.bashrc` or `~/.bash_profile`, for zshell, it's `~/.zshrc`)
* Add the following: `export JAVA_HOME=<path_to_installation_directory>/openjdk@11` (for example, `export JAVA_HOME=/opt/homebrew/opt/openjdk@11`
* Also add `export PATH=$JAVA_HOME/bin:$PATH`
* Save and close the config file, then source it with `source <config_file>` (for example `source ~/.zshrc`)
* Make sure your local environment sees Java 11 as the default version with `java -version`. You should see something like this:
```
openjdk version "11.0.23" 2024-04-16
OpenJDK Runtime Environment Homebrew (build 11.0.23+0)
OpenJDK 64-Bit Server VM Homebrew (build 11.0.23+0, mixed mode)
```
* Install the Maven build management tool with `brew install mvn` and then make sure the system recognizes it with `which mvn`
* `cd` into `cantaloupe-project/` and check out the current build branch (v5.0.5-nypl-implementation) if the submodule is not already at the head of that branch.
* try to build the project with `mvn clean package -DskipTests`. If there are no bugs in the code, it should build successfully. The output files should be in `cantaloupe-project/target/`.
* Copy the newly built .jar file out of `target/` and into the root of the NYPL/cantaloupe.git project. Make sure it is named `cantaloupe-5.0.5.jar`. It should overwrite the existing jarfile.
* The next time you build the NYPL cantaloupe project with `docker-compose build`, the new server code will become effective.

## Installing

This uses Docker to locally to make it as easy as possible for developers to install.

1.  `cp .env.example .env` (and fill in .env with credentials)
2.  Optional: To work locally on the shim, edit `nginx-configs/image_server_to_iiif.js` and comment out line 54 and comment in line 58. (NB: Make sure to revert these changes for deployment.)
3.  `docker-compose build`
4.  `docker-compose up`
4.  Test in a browser: http://localhost:8182/iiif/2/53926/full/full/0/default.jpg
5.  Test shim in a browser: http://localhost:8080/index.php?id=53926&t=f

## Using

This branch looks for source images in the `./images` directory, which is mounted in the container at `/var/www/images.nypl.org`.

Source and derivative images are cached in `./cache`, which is mounted into the container at `/ifs/prod/iiif-imagecache`.

You can download images from the production repo and put them into `./repo` using the correct directory structure. If you then connect your local canteloupe instance to the qa filestore, as long as the added images exist in that database, the local shim should be able to serve them. This is useful for testing images that don't render.

## Testing Images Locally
- Update `nginx-configs/image_server_to_iiif.js` for local shim use as mentioned above.
- Configure DB_URL, DB_UNAME, and DB_PASS in .env to connect to the qa or production filestore database
- Download an image from the production image repo to your local.
- Note the image's filepath as you're doing this. You can also find the path by attempting to render the image using the shim locally as long as you're connected to a remote filestore database from local. The filepath will be in the stack trace shown in the browser.
- Create the image's filepath directory in your local `repo` folder with `mkdir -p <path_without_filename>` (for example: `mkdir -p /B1/B116/AD22/0697/11E2/9D4C/8488/957D/67`). Then, copy the downloaded image into the created directory.
- Rebuild your containers and run them. You should now be able to use the local shim to view the downloaded image.

## Running Unit Tests
- Install jruby on your local (homebrew is fine on mac)
- Do `jruby test/<test_file_name>` to run tests

## Git Workflow

Our branches (in order or stability are):

| Branch     | Environment | AWS Account      | Example link (shim)                                 | Admin Panel                    |
|:-----------|:------------|:-----------------|:----------------------------------------------------|:-------------------------------|
| develop    | none        | NA               | NA                                                  | http://localhost:8182/admin    |
| qa         | qa          | nypl-digital-dev | https://iiif-qa.nypl.org/index.php?id=1590363&t=w   | https://qa-iiif.nypl.org/admin |
| production | production  | nypl-digital-dev | https://iiif-prod.nypl.org/index.php?id=1590363&t=w | https://iiif.nypl.org/admin    |

1. Feature branches are cut from `develop`.
2. Once the feature branch is ready to be merged, file a pull request of the branch _into_ develop.
3. Branches are "promoted" by merging from less stable to more. (develop -> qa -> production )
4. Always make sure to revert to deployment settings in the secrets.rb before commiting changes to deploy.

## Deployment

We use Bamboo for deployments. The canteloupe.properties.dev config file is applied for qa deployments, and the canteloupe.properties.prod config file is applied for production deployments. The previous properties file on the server is moved to canteloupe.properties.old.

The deployed servers do not run in docker, so the deploy scripts (configured in bamboo) are responsible for repeating the steps in the dockerfile to configure and deploy the new server and restart the service. Each server instance is updated in sequence prevent service downtime.

| Job ...                                          | Deploys branch ... | Deploys to ...                  | Shim ...                     |
|:-------------------------------------------------|:-------------------|:--------------------------------|:-----------------------------|
| `https://bamboo02.nypl.org/browse/DS-IQDS`       | `qa`               | https://iiif-qa-native.nypl.org | http://iiif-qa-shim.nypl.org |
| `https://bamboo02.nypl.org/browse/DS-IPDS`       | `production`       | https://iiif-native.nypl.org    | https://iiif-shim.nypl.org   |
