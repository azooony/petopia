import { NextFunction, Request, Response } from "express";
import { type ZodTypeAny } from "zod";
export declare const validate: (schema: ZodTypeAny) => (req: Request, _res: Response, next: NextFunction) => Promise<void>;
//# sourceMappingURL=validate.middleware.d.ts.map