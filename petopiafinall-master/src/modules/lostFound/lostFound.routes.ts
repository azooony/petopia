import { Router } from "express";
import { protect } from "../../common/middlewares/auth.middleware";
import { validate } from "../../common/middlewares/validate.middleware";
import { uploadLostFound } from "../../common/middlewares/upload.middleware";
import { LostFoundController } from "./lostFound.controller";
import { ReportLostPetSchema, ReportFoundPetSchema } from "./lostFound.dto";

const router = Router();

router.post(
  "/lost",
  protect,
  uploadLostFound.array("images", 5),
  validate(ReportLostPetSchema),
  LostFoundController.reportLostPet,
);

router.get("/lost", protect, LostFoundController.getLostReports);

router.post(
  "/found",
  protect,
  uploadLostFound.array("images", 5),
  validate(ReportFoundPetSchema),
  LostFoundController.reportFoundPet,
);

router.get("/found", protect, LostFoundController.getFoundReports);

export default router;
