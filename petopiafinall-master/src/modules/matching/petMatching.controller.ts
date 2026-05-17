import { Response, NextFunction } from "express";

import { AuthRequest } from "../../common/middlewares/auth.middleware";

import { PetMatchingService } from "./petMatching.service";
import { FindMatchesQuerySchema } from "./petMatching.dto";

export class PetMatchingController {

  static createProfile = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {

      const profile =
        await PetMatchingService.createProfile(
          req.user!.userId,
          req.body
        );

      res.status(201).json({
        success: true,
        data: profile,
      });

    } catch (err) {
      next(err);
    }
  };

  static updateProfile = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {

      const profile =
        await PetMatchingService.updateProfile(
          req.user!.userId,
          req.params.petId as string,
          req.body
        );

      res.json({
        success: true,
        data: profile,
      });

    } catch (err) {
      next(err);
    }
  };

  static getProfile = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const data = await PetMatchingService.getProfile(
        req.user!.userId,
        req.params.petId as string,
      );
      res.json({ success: true, data });
    } catch (err) {
      next(err);
    }
  };

  static findMatches = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const query =
        FindMatchesQuerySchema.parse(req.query);

      const data =
        await PetMatchingService.findMatches(
          req.user!.userId,
          req.params.petId as string,
          query.page,
          query.limit,
          query.gender,
        );

      res.json({
        success: true,
        data,
      });

    } catch (err) {
      next(err);
    }
  };

  static deleteProfile = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      await PetMatchingService.deleteProfile(
        req.user!.userId,
        req.params.petId as string,
      );
      res.json({ success: true, message: "Match profile removed" });
    } catch (err) {
      next(err);
    }
  };

  static findAllMatches = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const query = FindMatchesQuerySchema.parse(req.query);
      const data  = await PetMatchingService.findAllMatches(
        query.page,
        query.limit,
        query.gender,
        query.type,
      );
      res.json({ success: true, data });
    } catch (err) {
      next(err);
    }
  };

  static sendRequest = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {

      const data =
        await PetMatchingService.sendMatchRequest(
          req.user!.userId,
          req.body
        );

      res.status(201).json({
        success: true,
        data,
      });

    } catch (err) {
      next(err);
    }
  };

  static getIncomingRequests = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {

      const data =
        await PetMatchingService.getIncomingRequests(
          req.user!.userId,
          req.params.petId as string
        );

      res.json({
        success: true,
        data,
      });

    } catch (err) {
      next(err);
    }
  };

  static acceptRequest = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {

      const data =
        await PetMatchingService.acceptRequest(
          req.user!.userId,
          req.params.requestId as string
        );

      res.json({
        success: true,
        message: "Match accepted",
        data,
      });

    } catch (err) {
      next(err);
    }
  };

  static rejectRequest = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ) => {
    try {

      const data =
        await PetMatchingService.rejectRequest(
          req.user!.userId,
          req.params.requestId as string
        );

      res.json({
        success: true,
        message: "Match rejected",
        data,
      });

    } catch (err) {
      next(err);
    }
  };
}