import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import requestRoutes from "./routes/requestRoutes.js";
import authRoutes from "./routes/authRoutes.js";
import adminTools from "./routes/adminTools.js";
import "./config/db.js";
import path from "path";
import { fileURLToPath } from "url";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware 

app.use(cors({
  origin: "https://giltech-frontend.vercel.app",
  methods: ["GET", "POST", "PUT", "DELETE"],
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Root route
app.get("/", (req, res) => {
  res.send("✅ Giltech Online Cyber API running with MySQL...");
});

// API routes
app.use("/api/requests", requestRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/admin-tools", adminTools);

// Serve frontend static files
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const frontendPath = path.join(__dirname, "..", "GIL");
app.use(express.static(frontendPath));

// Fallback to index.html for client-side routing
app.use((req, res) => {
  if (req.path.startsWith("/api")) {
    return res.status(404).json({ error: "Not found" });
  }
  res.sendFile(path.join(frontendPath, "index.html"));
});

// Start Server
app.listen(PORT, () =>
  console.log(`🚀 Server running on http://localhost:${PORT}`)
);
