FROM nginx:latest
LABEL maintainer "fraoustin@gmail.com"

ENV SET_CONTAINER_TIMEZONE false 
ENV CONTAINER_TIMEZONE ""
ENV DISABLE_AUTH false

# manage user www-data
RUN usermod -u 1000 www-data

# manage start container
COPY ./src/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir /usr/share/docker-entrypoint.pre &&  mkdir /usr/share/docker-entrypoint.post
COPY ./src/00_init.sh /usr/share/docker-entrypoint.pre/00_init.sh
RUN chmod +x -R /usr/share/docker-entrypoint.pre

# install extra nginx
RUN apt-get update && apt-get install -y \
        apache2-utils \
        git \
        nginx-extras \
        wget \
    && rm -rf /var/lib/apt/lists/* 

COPY ./src/nginx/* /etc/nginx/conf.d/
RUN rm /etc/nginx/sites-enabled/default

# add cmd nginx
COPY ./src/cmd/addauth.sh /usr/bin/addauth
COPY ./src/cmd/rmauth.sh /usr/bin/rmauth
RUN chmod +x /usr/bin/addauth && chmod +x /usr/bin/rmauth

# add theme
RUN mkdir /theme
WORKDIR /theme
RUN wget https://github.com/alehaa/nginx-fancyindex-flat-theme/releases/download/v1.1/nginx-fancyindex-flat-theme-1.1.tar.gz && tar xvzf nginx-fancyindex-flat-theme-1.1.tar.gz && rm nginx-fancyindex-flat-theme-1.1.tar.gz && rm flat-theme/theme.css
COPY ./src/theme.css flat-theme/theme.css
#ENV COLOR "blue" 

RUN mkdir /share
VOLUME /share

ENV WEBUSER user
ENV WEBPASSWORD pass

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["app"]
