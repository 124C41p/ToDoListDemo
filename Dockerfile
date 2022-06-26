FROM --platform=linux/amd64 node:14.17.3-alpine AS app-builder
WORKDIR /app
COPY package.json package-lock.json webpack.config.js elm.json ./
COPY src src
RUN npm i
RUN npm run build

FROM --platform=linux/arm/v7 node:14.17.3-alpine
WORKDIR /server
COPY package.json package-lock.json webpack.config.js ./
COPY server server
COPY --from=app-builder /app/dist ./dist
COPY static static
ARG NODE_ENV=production
RUN npm i
ENTRYPOINT [ "npm", "start" ]
EXPOSE 8080