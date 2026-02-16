import cors from "cors";
import dotenv from "dotenv";
import express from "express";
import morgan from "morgan";
import db from "./config/database.js";
import authRoutes from "./routes/auth.routes.js";
import usuarioRoutes from "./routes/usuario.routes.js";

dotenv.config();

const app = express();

app.use(cors());
app.use(morgan("dev"));
app.use(express.json());

// Endpoints
app.use("/auth", authRoutes);
app.use("/usuarios", usuarioRoutes);

app.get("/", (req, res) => {
  res.json({ message: "API Biblioteca Escolar activa 📚" });
});

//Para probar que la conexión es exitosa probar http://localhost:3000/db-check
app.get("/db-check", async (req, res) => {
  try {
    await db.query("SELECT 1");
    res.json({
      connected: true,
      message: "Conexión exitosa a la base de datos",
    });
  } catch (error) {
    res.status(500).json({
      connected: false,
      message: "Error de conexión a la base de datos",
      error: error.message,
    });
  }
});

export default app;
