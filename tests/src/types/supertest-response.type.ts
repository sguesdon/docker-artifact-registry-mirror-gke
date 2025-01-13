import { Response } from "supertest";

export type SuperTestResponse<T> = Omit<Response, "body"> & { body: T };
