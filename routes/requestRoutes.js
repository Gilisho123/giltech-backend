import express from "express";
import upload from "../middleware/uploadMiddleware.js";
import { addRequest, listRequests } from "../controllers/requestController.js";
import ensureAdmin from "../middleware/ensureAdmin.js";

const router = express.Router();

router.post("/", upload.single("document"), addRequest);
// Protect the GET list route with ensureAdmin middleware
router.get("/", ensureAdmin, listRequests);

export default router;
