import { Request, Response, NextFunction } from 'express';
import multer from "multer";
import { AppError } from "../errors/AppError";

export const errorMiddleware = (
  err: any,
  _req: Request,
  res: Response,
  _next: NextFunction
) => {
  const statusCode =
    err instanceof AppError ? err.statusCode : err instanceof multer.MulterError ? 400 : 500;
  const message = err.message || "Internal Server Error";

  res.status(statusCode).json({
    success: false,
    message,
    error: process.env.NODE_ENV === 'development' ? err.stack : message,
  });
};
