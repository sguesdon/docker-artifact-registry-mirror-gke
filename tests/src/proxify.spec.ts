import { mockServerRequest, mirrorRequest } from "./config/config";
import { SuperTestResponse } from "./server/types/supertest-response.type";
import {
  ANY_ROUTE_URI,
  FORWARDED_IMAGE_NAME_URI,
  FORWARDED_MISSING_IMAGE_NAME_URI,
  IMAGE_NAME_URI,
  MISSING_IMAGE_NAME_URI,
} from "./config/routes";

describe("proxify repository requests", () => {
  it("should success proxify using /v2/ rewrite", async () => {
    const res = await mirrorRequest.get(IMAGE_NAME_URI);
    expect(res.statusCode).toEqual(200);

    const { body: mockServerRequests }: SuperTestResponse<Request[]> =
      await mockServerRequest.get("/requests").query({
        query: JSON.stringify({
          path: FORWARDED_IMAGE_NAME_URI,
        }),
      });

    expect(mockServerRequests).toHaveLength(1);
    expect(mockServerRequests[0]).toMatchObject({
      uri: FORWARDED_IMAGE_NAME_URI,
      statusCode: 200,
      method: "GET",
    });
  });

  it("should sucess proxify using / rewrite", async () => {
    const res = await mirrorRequest.get(ANY_ROUTE_URI);
    expect(res.statusCode).toEqual(200);

    const { body: mockServerRequests }: SuperTestResponse<Request[]> =
      await mockServerRequest.get("/requests").query({
        query: JSON.stringify({
          path: ANY_ROUTE_URI,
        }),
      });

    expect(mockServerRequests).toHaveLength(1);
    expect(mockServerRequests[0]).toMatchObject({
      method: "GET",
      uri: ANY_ROUTE_URI,
      statusCode: 200,
    });
  });

  it("should failed because mock server return 404", async () => {
    const res = await mirrorRequest.get(MISSING_IMAGE_NAME_URI);
    expect(res.statusCode).toEqual(404);

    const { body: mockServerRequests }: SuperTestResponse<Request[]> =
      await mockServerRequest.get("/requests").query({
        query: JSON.stringify({
          path: FORWARDED_MISSING_IMAGE_NAME_URI,
        }),
      });

    expect(mockServerRequests).toHaveLength(1);
    expect(mockServerRequests[0]).toMatchObject({
      method: "GET",
      uri: FORWARDED_MISSING_IMAGE_NAME_URI,
      statusCode: 404,
    });
  });
});
