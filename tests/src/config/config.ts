import request from "supertest";
import { MIRROR_HOSTNAME, MOCK_SERVER_HOSTNAME } from "./routes";

export const mirrorRequest = request(`http://${MIRROR_HOSTNAME}`);
export const mockServerRequest = request(`http://${MOCK_SERVER_HOSTNAME}`);

beforeEach(() =>
  request(`http://${MOCK_SERVER_HOSTNAME}`).post("/requests/reset")
);
