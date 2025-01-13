FROM nginxinc/nginx-unprivileged:1.27-bookworm

# manage start container
COPY ./src/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# install extra nginx
RUN apt-get update && apt-get install -y \
        apache2-utils \
        git \
        nginx-extras \
        wget \
    && rm -rf /var/lib/apt/lists/*

COPY ./src/nginx/* /etc/nginx/conf.d/
RUN rm /etc/nginx/sites-enabled/default

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
