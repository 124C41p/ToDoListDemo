FROM node:alpine
WORKDIR /server
COPY package.json package-lock.json ./
COPY src src
COPY public public
RUN npm i
ENTRYPOINT [ "npm", "start" ]
EXPOSE 8080