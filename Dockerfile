FROM node:alpine
WORKDIR /server
COPY package.json package-lock.json elm.json webpack.config.js ./
COPY server server
COPY src src
COPY static static
RUN npm i
RUN npm run build
ENTRYPOINT [ "npm", "start" ]
EXPOSE 8080