import { Response, NextFunction } from "express";
import { AuthRequest } from "../../common/middlewares/auth.middleware";
export declare class SittingController {
    static createSitterProfile(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static getSitterProfileMe(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static getSitterProfile(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static updateSitterProfile(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static uploadSitterImage(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static getSitterImages(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static deleteSitterImage(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static addAvailability(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static getMyAvailability(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static deleteAvailability(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static createBooking(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static getMyBookingsAsSitter(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static getIncomingBookings(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static getMyBookingsAsOwner(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static acceptBooking(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static rejectBooking(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static cancelBooking(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static createReview(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static getSitterReviews(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static searchSitters(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static getPendingSitters(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static approveSitter(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
    static rejectSitter(req: AuthRequest, res: Response, next: NextFunction): Promise<void | Response<any, Record<string, any>>>;
}
//# sourceMappingURL=sitting.controller.d.ts.map