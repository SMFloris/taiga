FROM node:16.19.1-bullseye AS build
WORKDIR /src

# Some locked dependencies use Git SSH URLs; fetch them over HTTPS instead.
RUN git config --global url."https://github.com/".insteadOf ssh://git@github.com/
COPY taiga-front/package.json taiga-front/package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY taiga-front/ ./
RUN npx --no-install gulp deploy

FROM nginx:1.28-alpine
RUN apk add --no-cache bash
COPY taiga-front/docker/default.conf /etc/nginx/conf.d/default.conf
COPY taiga-front/docker/config_env_subst.sh /docker-entrypoint.d/30_config_env_subst.sh
COPY --from=build /src/dist/ /usr/share/nginx/html/
COPY taiga-front/docker/conf.json.template /usr/share/nginx/html/conf.json.template
RUN chmod +x /docker-entrypoint.d/30_config_env_subst.sh \
    && rm -f /usr/share/nginx/html/conf.json
