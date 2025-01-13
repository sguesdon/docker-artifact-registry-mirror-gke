import { mirrorRequest, mockServerRequest } from "./config/config";
import {
  ERROR_IMAGE_NAME_URI,
  FORWARDED_ERROR_IMAGE_NAME_URI,
  FORWARDED_IMAGE_NAME_URI,
  FORWARDED_MISSING_IMAGE_NAME_URI,
  IMAGE_NAME_URI,
} from "./config/routes";
import { Request } from "./server/types/request.type";
import { SuperTestResponse } from "./server/types/supertest-response.type";

describe("authz cache management", () => {
  it("should success call after reload bearer cache token in mirror service", async () => {
    // update token parsed by sidecar
    await mockServerRequest
      .put("/token")
      .set("Content-Type", "text/plain")
      .buffer(true)
      .parse((res, cb) => {
        let data = Buffer.from("");
        res.on("data", (chunk) => (data = Buffer.concat([data, chunk])));
        res.on("end", () => cb(null, data.toString()));
      })
      .send("xyz");

    // wait sidecar parse new token calling mock server
    await new Promise((resolve) => setTimeout(resolve, 2000));

    // call mirror server
    const mirrorResponse = await mirrorRequest.get(IMAGE_NAME_URI);

    expect(mirrorResponse.statusCode).toEqual(200);

    const { body: mockServerRequests }: SuperTestResponse<Request[]> =
      await mockServerRequest
        .get("/requests")
        .query({ query: JSON.stringify({ path: FORWARDED_IMAGE_NAME_URI }) });

    // first call bearer is invalid and mock server return 401
    expect(mockServerRequests).toHaveLength(2);
    expect(mockServerRequests[0]).toMatchObject({
      uri: FORWARDED_IMAGE_NAME_URI,
      statusCode: 401,
      headers: expect.objectContaining({
        authorization: "Bearer abcd",
      }),
    });

    // after cache reload, mirror use updated bearer and mock server return 200
    expect(mockServerRequests[1]).toMatchObject({
      uri: FORWARDED_IMAGE_NAME_URI,
      statusCode: 200,
      headers: expect.objectContaining({
        authorization: "Bearer xyz",
      }),
    });
  });

  it("should failed because unauthorized", async () => {
    const mirrorResponse = await mirrorRequest.get(ERROR_IMAGE_NAME_URI);

    expect(mirrorResponse.statusCode).toEqual(500);

    const { body: mockServerRequests }: SuperTestResponse<Request[]> =
      await mirrorRequest.get("/requests").query({
        query: JSON.stringify({ path: FORWARDED_ERROR_IMAGE_NAME_URI }),
      });

    expect(mockServerRequests).toHaveLength(3);
    for (const mockServerRequest of mockServerRequests) {
      expect(mockServerRequest).toMatchObject({
        uri: FORWARDED_ERROR_IMAGE_NAME_URI,
        statusCode: 401,
      });
    }
  });
});
