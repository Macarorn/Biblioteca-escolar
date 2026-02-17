import { Router } from "express";
import * as devolucionController from "../controllers/devolucionController.js";

const router = Router();

router.get("/", devolucionController.getDevoluciones);
router.get("/:id", devolucionController.getDevolucionById);

export default router;
