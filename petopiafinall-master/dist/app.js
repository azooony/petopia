"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const path_1 = __importDefault(require("path"));
const auth_routes_1 = __importDefault(require("./modules/auth/auth.routes"));
const user_routes_1 = __importDefault(require("./modules/users/user.routes"));
const clinic_routes_1 = __importDefault(require("./modules/clinics/clinic.routes"));
const admin_routes_1 = __importDefault(require("./modules/admin/admin.routes"));
const vet_routes_1 = __importDefault(require("./modules/vet/vet.routes"));
const appointments_routes_1 = __importDefault(require("./modules/appointments/appointments.routes"));
const error_middleware_1 = require("./common/middlewares/error.middleware");
const pets_routes_1 = __importDefault(require("./modules/pets/pets.routes"));
const sitting_routes_1 = __importDefault(require("./modules/sitting/sitting.routes"));
const petMatching_routes_1 = __importDefault(require("./modules/matching/petMatching.routes"));
const chat_routes_1 = __importDefault(require("./modules/chat/chat.routes"));
const lostFound_routes_1 = __importDefault(require("./modules/lostFound/lostFound.routes"));
const ai_routes_1 = __importDefault(require("./modules/ai/ai.routes"));
const notification_routes_1 = __importDefault(require("./modules/Notification/notification.routes"));
const search_routes_1 = __importDefault(require("./modules/search/search.routes"));
const app = (0, express_1.default)();
app.use((0, cors_1.default)({
    origin: (origin, callback) => {
        // Mobile apps (Flutter) send no Origin header — always allow them.
        if (!origin)
            return callback(null, true);
        // Allow any localhost origin for development (Flutter web uses a random port).
        if (origin.startsWith("http://localhost"))
            return callback(null, true);
        const allowed = (process.env.FRONTEND_URL ?? "http://localhost:5173").split(",");
        if (allowed.includes(origin))
            return callback(null, true);
        callback(new Error(`CORS: origin ${origin} not allowed`));
    },
    credentials: true,
}));
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
app.use("/uploads", express_1.default.static(path_1.default.join(process.cwd(), "uploads")));
app.get("/", (_req, res) => {
    res.status(200).json({
        success: true,
        message: "Petopia API is running",
        data: { status: "ok" },
    });
});
app.use("/auth", auth_routes_1.default);
app.use("/users", user_routes_1.default);
app.use("/clinic", clinic_routes_1.default);
app.use("/admin", admin_routes_1.default);
app.use("/vets", vet_routes_1.default);
app.use("/appointments", appointments_routes_1.default);
app.use("/sitting", sitting_routes_1.default);
app.use("/pets", pets_routes_1.default);
app.use("/matching", petMatching_routes_1.default);
app.use("/chat", chat_routes_1.default);
app.use("/lost-found", lostFound_routes_1.default);
app.use("/ai", ai_routes_1.default);
app.use("/notifications", notification_routes_1.default);
app.use("/search", search_routes_1.default);
app.use((_req, res) => {
    res.status(404).json({
        success: false,
        message: "Route not found",
        error: "Route not found",
    });
});
app.use(error_middleware_1.errorMiddleware);
exports.default = app;
//# sourceMappingURL=app.js.map