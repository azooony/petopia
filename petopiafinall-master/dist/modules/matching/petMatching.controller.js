"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PetMatchingController = void 0;
const petMatching_service_1 = require("./petMatching.service");
const petMatching_dto_1 = require("./petMatching.dto");
class PetMatchingController {
    static createProfile = async (req, res, next) => {
        try {
            const profile = await petMatching_service_1.PetMatchingService.createProfile(req.user.userId, req.body);
            res.status(201).json({
                success: true,
                data: profile,
            });
        }
        catch (err) {
            next(err);
        }
    };
    static updateProfile = async (req, res, next) => {
        try {
            const profile = await petMatching_service_1.PetMatchingService.updateProfile(req.user.userId, req.params.petId, req.body);
            res.json({
                success: true,
                data: profile,
            });
        }
        catch (err) {
            next(err);
        }
    };
    static getProfile = async (req, res, next) => {
        try {
            const data = await petMatching_service_1.PetMatchingService.getProfile(req.user.userId, req.params.petId);
            res.json({ success: true, data });
        }
        catch (err) {
            next(err);
        }
    };
    static findMatches = async (req, res, next) => {
        try {
            const query = petMatching_dto_1.FindMatchesQuerySchema.parse(req.query);
            const data = await petMatching_service_1.PetMatchingService.findMatches(req.user.userId, req.params.petId, query.page, query.limit, query.gender);
            res.json({
                success: true,
                data,
            });
        }
        catch (err) {
            next(err);
        }
    };
    static deleteProfile = async (req, res, next) => {
        try {
            await petMatching_service_1.PetMatchingService.deleteProfile(req.user.userId, req.params.petId);
            res.json({ success: true, message: "Match profile removed" });
        }
        catch (err) {
            next(err);
        }
    };
    static findAllMatches = async (req, res, next) => {
        try {
            const query = petMatching_dto_1.FindMatchesQuerySchema.parse(req.query);
            const data = await petMatching_service_1.PetMatchingService.findAllMatches(query.page, query.limit, query.gender, query.type);
            res.json({ success: true, data });
        }
        catch (err) {
            next(err);
        }
    };
    static sendRequest = async (req, res, next) => {
        try {
            const data = await petMatching_service_1.PetMatchingService.sendMatchRequest(req.user.userId, req.body);
            res.status(201).json({
                success: true,
                data,
            });
        }
        catch (err) {
            next(err);
        }
    };
    static getIncomingRequests = async (req, res, next) => {
        try {
            const data = await petMatching_service_1.PetMatchingService.getIncomingRequests(req.user.userId, req.params.petId);
            res.json({
                success: true,
                data,
            });
        }
        catch (err) {
            next(err);
        }
    };
    static acceptRequest = async (req, res, next) => {
        try {
            const data = await petMatching_service_1.PetMatchingService.acceptRequest(req.user.userId, req.params.requestId);
            res.json({
                success: true,
                message: "Match accepted",
                data,
            });
        }
        catch (err) {
            next(err);
        }
    };
    static rejectRequest = async (req, res, next) => {
        try {
            const data = await petMatching_service_1.PetMatchingService.rejectRequest(req.user.userId, req.params.requestId);
            res.json({
                success: true,
                message: "Match rejected",
                data,
            });
        }
        catch (err) {
            next(err);
        }
    };
}
exports.PetMatchingController = PetMatchingController;
//# sourceMappingURL=petMatching.controller.js.map