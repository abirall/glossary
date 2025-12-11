
FROM klakegg/hugo:ext-alpine AS builder

RUN apk add --no-cache git

WORKDIR /site

COPY . .


RUN git submodule update --init --recursive \
 && hugo --minify -d /output/public


FROM nginx:alpine AS final

RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /output/public /usr/share/nginx/html


RUN printf 'server {\n\
  listen       8080;\n\
  server_name  _;\n\
  root   /usr/share/nginx/html;\n\
  index  index.html index.htm;\n\
  location / {\n\
    try_files $uri $uri/ /index.html;\n\
  }\n\
}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
