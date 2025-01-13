export interface Request {
  method: string;
  headers: Record<string, string>;
  body: object;
  uri: string;
  statusCode: number;
}
