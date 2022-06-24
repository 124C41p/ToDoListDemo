# To Do List Demo

## Run in development mode:

```
docker run -e POSTGRES_HOST_AUTH_METHOD=trust -p 5432:5432 -d postgres
npm install
npm run start:dev
```

## Run in production mode:

```
docker-compose up --build -d
```