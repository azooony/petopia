import jwt from "jsonwebtoken";
import { UserRole } from "../../../generated/prisma";

const JWT_SECRET = process.env.JWT_SECRET!;

export interface JwtPayload {
  userId: string;
  role: UserRole;
}

export const generateToken = (payload: JwtPayload): string => {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: "7d" });
};

export const verifyToken = (token: string): JwtPayload => {
  return jwt.verify(token, JWT_SECRET) as JwtPayload;
};