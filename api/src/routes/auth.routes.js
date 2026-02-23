import { Router } from "express";
import { changePassword, login } from "../controllers/authController.js";

const router = Router();

// Iniciar sesión
router.post("/login", login);

// Cambiar contraseña
router.put("/change-password", changePassword);

export default router;
