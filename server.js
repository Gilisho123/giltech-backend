import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import requestRoutes from "./routes/requestRoutes.js";
import authRoutes from "./routes/authRoutes.js";
import adminTools from "./routes/adminTools.js";
import "./config/db.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors({
  origin: [
    "https://giltech-frontend.vercel.app",
    "http://localhost:5173"
  ],
  methods: ["GET", "POST", "PUT", "DELETE"],
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res.send("✅ Giltech Online Cyber API running with MySQL...");
});

app.use("/api/requests", requestRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/admin-tools", adminTools);

app.listen(PORT, () =>
  console.log(`🚀 Server running on port ${PORT}`)
);
