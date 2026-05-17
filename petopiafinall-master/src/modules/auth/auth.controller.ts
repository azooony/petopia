import { Request, Response, NextFunction } from "express";
import { AuthService } from "./auth.service";

export class AuthController {

  static registerPetOwner = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {

      const result = await AuthService.registerPetOwner(req.body);

      res.status(201).json({
        success: true,
        message: "Pet owner registered successfully",
        data: result,
      });

    } catch (err) {
      next(err);
    }
  };


  static registerVet = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      if (!req.file) {
        res.status(400).json({
          success: false,
          message: "Certificate image is required",
          error: "Certificate image is required",
        });
        return;
      }

      const result = await AuthService.registerVet(req.body, req.file);

      res.status(201).json({
        success: true,
        message: result.message,
        data: result.user,
      });

    } catch (err) {
      next(err);
    }
  };


  static login = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {

      const { email, password } = req.body;

      const result = await AuthService.login(email, password);

      res.status(200).json({
        success: true,
        message: "Login successful",
        data: result,
      });

    } catch (err) {
      next(err);
    }
  };

}
