import express from "express";
import cors from "cors";
import path from "path";
import authRoutes from "./modules/auth/auth.routes";
import userRoutes from "./modules/users/user.routes";
import clinicRoutes from "./modules/clinics/clinic.routes";
import adminRoutes from "./modules/admin/admin.routes";
import vetRoutes from "./modules/vet/vet.routes";
import appointmentRoutes from "./modules/appointments/appointments.routes";
import { errorMiddleware } from "./common/middlewares/error.middleware";
import petRoutes from "./modules/pets/pets.routes";
import sittingRoutes from "./modules/sitting/sitting.routes";
import matchingRoutes from "./modules/matching/petMatching.routes";
import chatRoutes from "./modules/chat/chat.routes";
import lostFoundRoutes from "./modules/lostFound/lostFound.routes";

const app = express();

app.use(
  cors({
    origin: (origin, callback) => {
      // Mobile apps (Flutter) send no Origin header — always allow them.
      if (!origin) return callback(null, true);
      // Allow any localhost origin for development (Flutter web uses a random port).
      if (origin.startsWith("http://localhost")) return callback(null, true);
      const allowed = (process.env.FRONTEND_URL ?? "http://localhost:5173").split(",");
      if (allowed.includes(origin)) return callback(null, true);
      callback(new Error(`CORS: origin ${origin} not allowed`));
    },
    credentials: true,
  })
);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/uploads", express.static(path.join(process.cwd(), "uploads")));

app.get("/", (_req, res) => {
  res.status(200).json({
    success: true,
    message: "Petopia API is running",
    data: { status: "ok" },
  });
});

app.use("/auth", authRoutes);
app.use("/users", userRoutes);
app.use("/clinic", clinicRoutes);
app.use("/admin", adminRoutes);
app.use("/vets", vetRoutes);
app.use("/appointments", appointmentRoutes);
app.use("/sitting", sittingRoutes);
app.use("/pets", petRoutes);
app.use("/matching", matchingRoutes);
app.use("/chat", chatRoutes);
app.use("/lost-found", lostFoundRoutes);

app.use((_req, res) => {
  res.status(404).json({
    success: false,
    message: "Route not found",
    error: "Route not found",
  });
});

app.use(errorMiddleware);

export default app;
