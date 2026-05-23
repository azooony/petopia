import { Response, NextFunction } from "express";
import { AuthRequest } from "../../common/middlewares/auth.middleware";
import { GeminiService, ChatMessage } from "./gemini.service";
import { AppError, HttpCode } from "../../common/errors/AppError";

export class AiController {
  static chat = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const { message, history } = req.body as {
        message: string;
        history?: ChatMessage[];
      };

      if (!message || typeof message !== "string" || !message.trim()) {
        return next(new AppError("Message is required", HttpCode.BAD_REQUEST));
      }

      const reply = await GeminiService.chat(message.trim(), history ?? []);

      res.json({
        success: true,
        message: "AI response generated successfully",
        data:    { reply },
        error:   null,
      });
    } catch (err: unknown) {
      // Surface Gemini API errors clearly instead of swallowing them
      const msg = err instanceof Error ? err.message : String(err);
      console.error("[Gemini]", msg);
      next(new AppError(`AI service error: ${msg}`, HttpCode.INTERNAL_SERVER_ERROR));
    }
  };
}
