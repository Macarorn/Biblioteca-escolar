import { Router } from "express";
import * as prestamoController from "../controllers/prestamoController.js";

const router = Router();

router.get("/", prestamoController.getPrestamos);
router.get("/vencidos", prestamoController.getPrestamosVencidos);
router.get("/:id", prestamoController.getPrestamoById);
router.post("/", prestamoController.createPrestamo);
router.put("/:id/estado", prestamoController.updateEstadoPrestamo);

export default router;
