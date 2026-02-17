import { Router } from "express";
import * as ejemplarController from "../controllers/ejemplarController.js";

const router = Router();

router.get("/", ejemplarController.getEjemplares);
router.get("/:id", ejemplarController.getEjemplarById);
router.post("/", ejemplarController.createEjemplar);
router.put("/:id", ejemplarController.updateEjemplar);
router.delete("/:id", ejemplarController.deleteEjemplar);

export default router;
