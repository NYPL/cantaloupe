FROM nginx:1.15.8

WORKDIR /etc/nginx
RUN rm ./conf.d/default.conf

ADD nginx_conf_local.conf ./nginx.conf
ADD images_proxy_local.conf ./conf.d/
ADD image_server_to_iiif.js ./conf.d/
