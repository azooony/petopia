import { Response, NextFunction } from "express";
import { AuthRequest } from "../../common/middlewares/auth.middleware";
import { PetService } from "./pets.service";
import { AppError, HttpCode } from "../../common/errors/AppError";
import { VisionClient } from "../../integrations/vision/VisionClient";

export class PetController {

  static createPet = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const pet = await PetService.createPet(req.user!.userId, req.body);

      res.status(201).json({
        success: true,
        message: "Pet created successfully",
        data: pet,
      });
    } catch (err) {
      next(err);
    }
  };

  static getMyPets = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const pets = await PetService.getMyPets(req.user!.userId, req.query);

      res.json({
        success: true,
        data: pets,
      });
    } catch (err) {
      next(err);
    }
  };

  static getPet = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const pet = await PetService.getPetById(
        req.user!.userId,
        req.params.id as string
      );

      res.json({ success: true, data: pet });
    } catch (err) {
      next(err);
    }
  };

  static updatePet = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const pet = await PetService.updatePet(
        req.user!.userId,
        req.params.id as string,
        req.body
      );

      res.json({ success: true, data: pet });
    } catch (err) {
      next(err);
    }
  };

  static deletePet = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      await PetService.deletePet(
        req.user!.userId,
        req.params.id as string
      );

      res.json({
        success: true,
        message: "Pet deleted",
      });
    } catch (err) {
      next(err);
    }
  };

  static uploadPhoto = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      if (!req.file) {
        throw new AppError('Photo file is required', HttpCode.BAD_REQUEST);
      }
      const petId = req.params.id as string;
      const photoUrl = `${req.protocol}://${req.get('host')}/uploads/pets/${req.file.filename}`;
      await PetService.uploadPetPhoto(req.user!.userId, petId, photoUrl);
      res.json({ success: true, data: { photoUrl } });
    } catch (err) {
      next(err);
    }
  };

  static analyzePhoto = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      if (!req.file) {
        throw new AppError('Photo file is required', HttpCode.BAD_REQUEST);
      }
      const result = await VisionClient.analyzePetImage(req.file.buffer, req.file.originalname);
      res.json({ success: true, data: result });
    } catch (err) {
      next(err);
    }
  };

  static uploadImage = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      if (!req.file) {
        throw new AppError("Image file is required", HttpCode.BAD_REQUEST);
      }

      const petId = req.params.id as string;
      const filename = req.file.filename;
      const imageUrl = `${req.protocol}://${req.get("host")}/uploads/pets/${filename}`;
      const storageKey = `pets/${filename}`;

      const image = await PetService.uploadPetImage(
        req.user!.userId,
        petId,
        imageUrl,
        storageKey,
      );

      res.json({ success: true, data: image });
    } catch (err) {
      next(err);
    }
  };
}
