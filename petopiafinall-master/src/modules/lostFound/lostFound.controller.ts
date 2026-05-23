import { Response, NextFunction } from "express";
import { AuthRequest } from "../../common/middlewares/auth.middleware";
import { LostFoundService } from "./lostFound.service";

export class LostFoundController {
  static reportLostPet = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const files = (req.files as Express.Multer.File[]) ?? [];
      const imageBuffers = files.map((f) => ({ buffer: f.buffer, filename: f.filename ?? f.originalname }));
      const baseUrl = `${req.protocol}://${req.get("host")}`;

      const report = await LostFoundService.reportLostPet(
        req.user!.userId,
        req.body,
        imageBuffers,
        baseUrl,
      );

      res.status(201).json({
        success: true,
        message: "Lost pet report submitted successfully",
        data:    report,
        error:   null,
      });
    } catch (err) {
      next(err);
    }
  };

  static reportFoundPet = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const files = (req.files as Express.Multer.File[]) ?? [];
      const imageBuffers = files.map((f) => ({ buffer: f.buffer, filename: f.filename ?? f.originalname }));
      const baseUrl = `${req.protocol}://${req.get("host")}`;

      const report = await LostFoundService.reportFoundPet(
        req.user!.userId,
        req.body,
        imageBuffers,
        baseUrl,
      );

      res.status(201).json({
        success: true,
        message: "Found pet report submitted successfully",
        data:    report,
        error:   null,
      });
    } catch (err) {
      next(err);
    }
  };

  static getLostReports = async (_req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const reports = await LostFoundService.getLostReports();
      res.json({
        success: true,
        message: "Lost pet reports retrieved successfully",
        data:    reports,
        error:   null,
      });
    } catch (err) {
      next(err);
    }
  };

  static getFoundReports = async (_req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const reports = await LostFoundService.getFoundReports();
      res.json({
        success: true,
        message: "Found pet reports retrieved successfully",
        data:    reports,
        error:   null,
      });
    } catch (err) {
      next(err);
    }
  };

  static deleteFoundReport = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      await LostFoundService.deleteFoundReport(req.user!.userId, req.params.id);
      res.json({
        success: true,
        message: "Found pet report deleted successfully",
        data:    null,
        error:   null,
      });
    } catch (err) {
      next(err);
    }
  };
}
