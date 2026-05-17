import { NextFunction, Request, Response } from "express";
import { z, type ZodTypeAny } from "zod";
import { AppError, HttpCode } from "../errors/AppError";

export const validate =
  (schema: ZodTypeAny) =>
  async (req: Request, _res: Response, next: NextFunction) => {
    try {
      req.body = await schema.parseAsync(req.body);
      next();
    } catch (error) {
      if (error instanceof z.ZodError) {
        return next(
          new AppError(
            error.issues.map((issue) => issue.message).join(", "),
            HttpCode.BAD_REQUEST
          )
        );
      }
      next(error);
    }
  };