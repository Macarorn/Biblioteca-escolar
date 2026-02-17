import { Router } from "express";
import * as libroController from "../controllers/libroController.js";

const router = Router();

router.get("/", libroController.getLibros);
router.get("/:id", libroController.getLibroById);
router.post("/", libroController.createLibro);
router.put("/:id", libroController.updateLibro);
router.delete("/:id", libroController.deleteLibro);

export default router;
