## What are these files for? 
The nginx files in the qa and production subfolders and for setting up shim to route 'images.nypl.org' requests to the IIIF server in a way that serves up the files as they are served by the standard php image resolver. 

These files should be deployed on the server to `/etc/nginx/conf.d/image_server_to_iiif.js`