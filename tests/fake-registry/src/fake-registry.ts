import {
  ANY_ROUTE_URI,
  FORWARDED_ERROR_IMAGE_NAME_URI,
  FORWARDED_IMAGE_NAME_URI,
  FORWARDED_MISSING_IMAGE_NAME_URI,
} from "./config/routes";

const ServerMock = require("mock-http-server");
const server = new ServerMock({ host: "0.0.0.0", port: 3000 });
let token = "abcd";

server.on({
  method: "GET",
  path: "/token",
  reply: {
    status: 200,
    header: { "content-type": "application/json" },
    body: () =>
      JSON.stringify({
        access_token: token,
      }),
  },
});

server.on({
  method: "PUT",
  path: "/token",
  reply: {
    status: 200,
    header: { "content-type": "application/json" },
    body: (request: any) => {
      token = request.body.access_token;
      console.log("updating token with value", token);
      return JSON.stringify({ access_token: token });
    },
  },
});

server.on({
  method: "GET",
  path: "/v2/",
  reply: {
    status: 200,
  },
});

server.on({
  method: "GET",
  path: "/health",
  reply: {
    status: 200,
  },
});

server.on({
  method: "GET",
  path: "/requests",
  reply: {
    status: 200,
    headers: { "content-type": "application/json" },
    body: (request: { query: { query: string } }) => {
      return JSON.stringify(
        server
          .requests(JSON.parse(request.query.query))
          .map((request: any) => ({
            method: request.method,
            headers: request.headers,
            body: request.body,
            uri: request.originalUrl,
            statusCode: request.statusCode,
          }))
      );
    },
  },
});

server.on({
  method: "POST",
  path: "/requests/reset",
  reply: {
    status: 200,
    body: () => server.resetRequests(),
  },
});

server.on({
  method: "GET",
  path: FORWARDED_IMAGE_NAME_URI,
  reply: {
    status: (request: any) => {
      request.statusCode =
        request.headers.authorization === `Bearer ${token}` ? 200 : 401;
      return request.statusCode;
    },
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ result: "ok" }),
  },
});

server.on({
  method: "GET",
  path: FORWARDED_MISSING_IMAGE_NAME_URI,
  reply: {
    status: (request: any) => {
      request.statusCode = 404;
      return request.statusCode;
    },
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ result: "ok" }),
  },
});

server.on({
  method: "GET",
  path: FORWARDED_ERROR_IMAGE_NAME_URI,
  reply: {
    status: (request: any) => {
      request.statusCode = 401;
      return request.statusCode;
    },
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ result: "ok" }),
  },
});

server.on({
  method: "GET",
  path: ANY_ROUTE_URI,
  reply: {
    status: (request: any) => {
      request.statusCode = 200;
      return request.statusCode;
    },
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ result: "ok" }),
  },
});

server.start(() => console.log("server started"));
