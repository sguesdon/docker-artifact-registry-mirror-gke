import { mirrorRequest, mockServerRequest } from "./config/config";
import {
  ERROR_IMAGE_NAME_URI,
  FORWARDED_ERROR_IMAGE_NAME_URI,
  FORWARDED_IMAGE_NAME_URI,
  IMAGE_NAME_URI,
} from "./config/routes";
import { Request } from "./types/request.type";
import { SuperTestResponse } from "./types/supertest-response.type";

describe("authz cache management", () => {
  it("should success call after reload bearer cache token in mirror service", async () => {
    const token = Date.now().toString();

    // first time call mirror server to load token
    await mirrorRequest.get(IMAGE_NAME_URI);

    // get orig token and update token
    const origTokenResponse = await mockServerRequest.get("/token");
    const origToken = origTokenResponse.body.access_token;
    await mockServerRequest.put("/token").send({ access_token: token });

    // call mirror server
    await mirrorRequest.get(IMAGE_NAME_URI);

    const { body: mockServerRequests }: SuperTestResponse<Request[]> =
      await mockServerRequest
        .get("/requests")
        .query({ query: JSON.stringify({ path: FORWARDED_IMAGE_NAME_URI }) });

    const requests = [
      {
        statusCode: 200,
        headers: expect.objectContaining({
          authorization: `Bearer ${origToken}`,
        }),
      },
      {
        uri: FORWARDED_IMAGE_NAME_URI,
        statusCode: 401,
        headers: expect.objectContaining({
          authorization: `Bearer ${origToken}`,
        }),
      },
      {
        uri: FORWARDED_IMAGE_NAME_URI,
        statusCode: 200,
        headers: expect.objectContaining({
          authorization: `Bearer ${token}`,
        }),
      },
    ];

    expect(mockServerRequests).toHaveLength(3);
    requests.forEach((request, index) =>
      expect(request).toMatchObject(requests[index])
    );
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
