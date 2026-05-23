import { Router } from "express";
import { protect } from "../../common/middlewares/auth.middleware";
import { ChatController } from "./chat.controller";

const router = Router();

router.use(protect);

router.post("/initiate",                               ChatController.initiate);
router.get("/conversations",                           ChatController.getConversations);
router.delete("/conversations/:conversationId",        ChatController.deleteConversation);
router.get("/conversations/:conversationId/messages",  ChatController.getMessages);

export default router;
