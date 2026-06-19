import multer, { StorageEngine } from "multer";
import path from "path";
import fs from "fs";
import { Request } from "express";
import { AppError, HttpCode } from "../errors/AppError";

function makeStorage(folder: string): StorageEngine {
  return multer.diskStorage({
    destination: (req: Request, file, cb) => {
      fs.mkdirSync(folder, { recursive: true });
      cb(null, folder);
    },
    filename: (req: Request, file, cb) => {
      const uniqueName = Date.now() + path.extname(file.originalname);
      cb(null, uniqueName);
    },
  });
}

function makeVetRegistrationStorage(): StorageEngine {
  return multer.diskStorage({
    destination: (req: Request, file, cb) => {
      const folder =
        file.fieldname === "photo" ? "uploads/vets/" : "uploads/certificates/";
      fs.mkdirSync(folder, { recursive: true });
      cb(null, folder);
    },
    filename: (req: Request, file, cb) => {
      const uniqueName = Date.now() + path.extname(file.originalname);
      cb(null, uniqueName);
    },
  });
}

const imageFilter = (req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  if (file.mimetype.startsWith("image/")) {
    cb(null, true);
  } else {
    cb(new AppError("Only images are allowed", HttpCode.BAD_REQUEST) as any, false);
  }
};

const limits = { fileSize: 5 * 1024 * 1024 };

export const upload = multer({
  storage: makeStorage("uploads/certificates/"),
  fileFilter: imageFilter,
  limits,
});

export const uploadVetRegistration = multer({
  storage: makeVetRegistrationStorage(),
  fileFilter: imageFilter,
  limits,
});

export const uploadPet = multer({
  storage: makeStorage("uploads/pets/"),
  fileFilter: imageFilter,
  limits,
});

export const uploadVet = multer({
  storage: makeStorage("uploads/vets/"),
  fileFilter: imageFilter,
  limits,
});

export const uploadAnalyze = multer({
  storage: multer.memoryStorage(),
  fileFilter: imageFilter,
  limits,
});

export const uploadLostFound = multer({
  storage: makeStorage("uploads/lost-found/"),
  fileFilter: imageFilter,
  limits,
});

export const uploadAvatar = multer({
  storage: makeStorage("uploads/avatars/"),
  fileFilter: imageFilter,
  limits,
});
