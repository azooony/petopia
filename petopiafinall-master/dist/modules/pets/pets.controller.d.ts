import { Response, NextFunction } from "express";
import { AuthRequest } from "../../common/middlewares/auth.middleware";
export declare class PetController {
    static createPet: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static getMyPets: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static getPet: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static updatePet: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static deletePet: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static uploadPhoto: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static analyzePhoto: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
    static uploadImage: (req: AuthRequest, res: Response, next: NextFunction) => Promise<void>;
}
//# sourceMappingURL=pets.controller.d.ts.map