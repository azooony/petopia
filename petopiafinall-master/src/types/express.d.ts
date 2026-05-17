// Augments Express.Request so TypeScript knows what `protect` attaches at runtime.
// The JWT middleware stores JwtPayload (userId + role), NOT a full database User row.
import { JwtPayload } from "../common/utils/jwt";

declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload;
      file?: Express.Multer.File;
    }
  }
}