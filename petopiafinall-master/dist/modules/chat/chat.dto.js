"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.GetMessagesQuerySchema = exports.InitiateConversationSchema = void 0;
const zod_1 = require("zod");
exports.InitiateConversationSchema = zod_1.z.object({
    targetUserId: zod_1.z.string().min(1, "targetUserId is required"),
    context: zod_1.z.enum(["MATCHING", "SITTING"]),
});
exports.GetMessagesQuerySchema = zod_1.z.object({
    page: zod_1.z.coerce.number().int().min(1).default(1),
    limit: zod_1.z.coerce.number().int().min(1).default(50).transform(v => Math.min(v, 100)),
});
//# sourceMappingURL=chat.dto.js.map