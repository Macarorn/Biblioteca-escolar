import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import db from "../config/database.js";

// POST /auth/login
export const login = async (req, res) => {
  const { documento, contrasena } = req.body;
  try {
    const [rows] = await db.query(
      `SELECT u.id_usuario, u.nombre, u.apellido, u.tipo_usuario, l.contrasena
       FROM usuarios u
       JOIN login l ON u.id_usuario = l.id_usuario
       WHERE l.documento = ?`,
      [documento],
    );
    if (rows.length === 0) {
      return res
        .status(401)
        .json({ message: "Usuario o contraseña incorrectos" });
    }
    const usuario = rows[0];
    const passwordMatch =
      contrasena === usuario.contrasena ||
      bcrypt.compareSync(contrasena, usuario.contrasena);
    if (!passwordMatch) {
      return res
        .status(401)
        .json({ message: "Usuario o contraseña incorrectos" });
    }
    const token = jwt.sign(
      { id: usuario.id_usuario, tipo: usuario.tipo_usuario },
      process.env.JWT_SECRET,
      { expiresIn: "8h" },
    );
    res.json({
      token,
      usuario: {
        id: usuario.id_usuario,
        nombre: usuario.nombre,
        apellido: usuario.apellido,
        tipo_usuario: usuario.tipo_usuario,
      },
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error en el login", error: error.message });
  }
};

// PUT /auth/change-password
export const changePassword = async (req, res) => {
  const { documento, contrasena_actual, contrasena_nueva } = req.body;
  try {
    const [rows] = await db.query(
      `SELECT id_login, contrasena FROM login WHERE documento = ?`,
      [documento],
    );
    if (rows.length === 0) {
      return res.status(404).json({ message: "Usuario no encontrado" });
    }
    const loginData = rows[0];
    const passwordMatch =
      contrasena_actual === loginData.contrasena ||
      bcrypt.compareSync(contrasena_actual, loginData.contrasena);
    if (!passwordMatch) {
      return res.status(401).json({ message: "Contraseña actual incorrecta" });
    }
    const hash = bcrypt.hashSync(contrasena_nueva, 10);
    await db.query(`UPDATE login SET contrasena = ? WHERE id_login = ?`, [
      hash,
      loginData.id_login,
    ]);
    res.json({ message: "Contraseña actualizada correctamente" });
  } catch (error) {
    res
      .status(500)
      .json({
        message: "Error al cambiar la contraseña",
        error: error.message,
      });
  }
};
