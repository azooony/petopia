"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.roleMiddleware = void 0;
const roleMiddleware = (...roles) => {
    return (req, res, next) => {
        if (!req.user) {
            res.status(401).json({ success: false, message: "Unauthorized", error: "Unauthorized" });
            return;
        }
        if (!roles.includes(req.user.role)) {
            res.status(403).json({ success: false, message: "Forbidden", error: "Forbidden" });
            return;
        }
        next();
    };
};
exports.roleMiddleware = roleMiddleware;
//# sourceMappingURL=role.middleware.js.map