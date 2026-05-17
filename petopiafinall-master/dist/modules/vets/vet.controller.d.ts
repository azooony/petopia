import { Request, Response, NextFunction } from 'express';
export declare const uploadCertificate: (req: Request, res: Response, next: NextFunction) => Promise<void>;
export declare const registerVetProfile: (req: Request, res: Response, next: NextFunction) => Promise<void>;
export declare const getMyProfile: (req: Request, res: Response, next: NextFunction) => Promise<void>;
export declare const updateProfile: (req: Request, res: Response, next: NextFunction) => Promise<void>;
export declare const verifyVet: (req: Request, res: Response, next: NextFunction) => Promise<void>;
export declare const addAvailabilitySlot: (req: Request, res: Response, next: NextFunction) => Promise<void>;
export declare const getAvailabilitySlots: (req: Request, res: Response, next: NextFunction) => Promise<void>;
export declare const updateAvailabilitySlot: (req: Request, res: Response, next: NextFunction) => Promise<void>;
export declare const deleteAvailabilitySlot: (req: Request, res: Response, next: NextFunction) => Promise<void>;
export declare const getUpcomingAppointments: (req: Request, res: Response, next: NextFunction) => Promise<void>;
//# sourceMappingURL=vet.controller.d.ts.map