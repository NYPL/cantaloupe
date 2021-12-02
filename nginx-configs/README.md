## What are these files for? 
The nginx files in the qa and production subfolders and for setting up shim to route 'images.nypl.org' requests to the IIIF server in a way that serves up the files as they are served by the standard php image resolver. 

These are symlinked on the server from `/etc/nginx/conf.d/image_server_to_iiif.js`. Any time a change is made and deployed, it is picked up by a restart of nginx. 

## Local Development: WIP
You can install nginx locally a few different ways. I run it locally by

`$ brew install nginx`
`$ sudo nginx`

With default configuration, that allows you to see your server running at `localhost:8080`

To add our custom IIIF configuration wrapper, I do

`$ mkdir /usr/local/etc/nginx/conf.d`
`$ cp image_server_to_iiif.js /usr/local/etc/nginx/conf.d/image_server_to_iiif.js`
`$ sudo /usr/local/bin/nginx -s stop`
`$ sudo nginx`

This should now serve as a wrapper for calls to your local IIIF server. You should be able to make calls in the old images.nypl.org if this is working properly, e.g., http://localhost:8080/index.php?id=1509405&t=f .