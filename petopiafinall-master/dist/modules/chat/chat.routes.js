"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../../common/middlewares/auth.middleware");
const chat_controller_1 = require("./chat.controller");
const router = (0, express_1.Router)();
router.use(auth_middleware_1.protect);
router.post("/initiate", chat_controller_1.ChatController.initiate);
router.get("/conversations", chat_controller_1.ChatController.getConversations);
router.delete("/conversations/:conversationId", chat_controller_1.ChatController.deleteConversation);
router.get("/conversations/:conversationId/messages", chat_controller_1.ChatController.getMessages);
exports.default = router;
//# sourceMappingURL=chat.routes.js.map