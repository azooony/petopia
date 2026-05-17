// clinic.controller.ts
import { Request, Response, NextFunction } from "express";
import prisma from "../../config/prisma"; //changed from import {prisma} from "../../config/prisma"
import { AppError, HttpCode } from "../../common/errors/AppError";

export const createClinic = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { name, address, phone } = req.body;

    if (!name || !address || !phone) {
      throw new AppError("Clinic name, address, and phone are required", HttpCode.BAD_REQUEST);
    }

    const clinic = await prisma.clinic.create({
      data: {
        name,
        address,
        phone,
      },
    });

    res.status(201).json({
      success: true,
      message: "Clinic created successfully",
      data: clinic,
    });
  } catch (err) {
    next(err);
  }
};
