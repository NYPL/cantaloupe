## What are these files for? 
The nginx files in the qa and production subfolders and for setting up shim to route 'images.nypl.org' requests to the IIIF server in a way that serves up the files as they are served by the standard php image resolver. 

These are symlinked on the server from `/etc/nginx/conf.d/image_server_to_iiif.js`. Any time a change is made and deployed, it is picked up by a restart of nginx. 