import { Router } from "express";
import * as solicitudController from "../controllers/solicitudController.js";

const router = Router();

router.get("/", solicitudController.getSolicitudes);
router.get("/:id", solicitudController.getSolicitudById);
router.post("/", solicitudController.createSolicitud);
router.put("/:id/estado", solicitudController.updateEstadoSolicitud);

export default router;
