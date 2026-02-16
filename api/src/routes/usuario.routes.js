import { Router } from "express";
import * as usuarioController from "../controllers/usuarioController.js";

const router = Router();

// Usuarios CRUD
router.get("/", usuarioController.getUsuarios);
router.get("/:id", usuarioController.getUsuarioById);
router.post("/", usuarioController.createUsuario);
router.put("/:id", usuarioController.updateUsuario);
router.delete("/:id", usuarioController.deleteUsuario);

// Relaciones de usuario
router.get("/:id/prestamos", usuarioController.getPrestamosByUsuario);
router.get("/:id/solicitudes", usuarioController.getSolicitudesByUsuario);
router.get("/:id/historial", usuarioController.getHistorialByUsuario);

export default router;
