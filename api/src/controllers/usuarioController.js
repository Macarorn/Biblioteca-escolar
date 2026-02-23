import db from "../config/database.js";

// GET /usuarios
export const getUsuarios = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM usuarios");
    res.json(rows);
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error al obtener usuarios", error: error.message });
  }
};

// GET /usuarios/:id
export const getUsuarioById = async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT * FROM usuarios WHERE id_usuario = ?",
      [req.params.id],
    );
    if (rows.length === 0)
      return res.status(404).json({ message: "Usuario no encontrado" });
    res.json(rows[0]);
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error al obtener usuario", error: error.message });
  }
};

// POST /usuarios
export const createUsuario = async (req, res) => {
  const { nombre, apellido, documento, tipo_usuario, contrasena } = req.body;
  try {
    const [result] = await db.query(
      "INSERT INTO usuarios (nombre, apellido, documento, tipo_usuario) VALUES (?, ?, ?, ?)",
      [nombre, apellido, documento, tipo_usuario],
    );
    await db.query(
      "INSERT INTO login (id_usuario, documento, contrasena) VALUES (?, ?, ?)",
      [result.insertId, documento, contrasena],
    );
    res
      .status(201)
      .json({ message: "Usuario creado", id_usuario: result.insertId });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error al crear usuario", error: error.message });
  }
};

// PUT /usuarios/:id
export const updateUsuario = async (req, res) => {
  const { nombre, apellido, documento, tipo_usuario } = req.body;
  try {
    const [result] = await db.query(
      "UPDATE usuarios SET nombre=?, apellido=?, documento=?, tipo_usuario=? WHERE id_usuario=?",
      [nombre, apellido, documento, tipo_usuario, req.params.id],
    );
    if (result.affectedRows === 0)
      return res.status(404).json({ message: "Usuario no encontrado" });
    res.json({ message: "Usuario actualizado" });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error al actualizar usuario", error: error.message });
  }
};

// DELETE /usuarios/:id
export const deleteUsuario = async (req, res) => {
  try {
    const [result] = await db.query(
      "DELETE FROM usuarios WHERE id_usuario = ?",
      [req.params.id],
    );
    if (result.affectedRows === 0)
      return res.status(404).json({ message: "Usuario no encontrado" });
    res.json({ message: "Usuario eliminado" });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error al eliminar usuario", error: error.message });
  }
};

// GET /usuarios/:id/prestamos
export const getPrestamosByUsuario = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT p.*, e.codigo_ejemplar, l.titulo FROM prestamos p
       JOIN ejemplares_libro e ON p.id_ejemplar = e.id_ejemplar
       JOIN libros l ON e.id_libro = l.id_libro
       WHERE p.id_usuario = ?`,
      [req.params.id],
    );
    res.json(rows);
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error al obtener préstamos", error: error.message });
  }
};

// GET /usuarios/:id/solicitudes
export const getSolicitudesByUsuario = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT s.*, l.titulo FROM solicitudes_prestamo s
       JOIN libros l ON s.id_libro = l.id_libro
       WHERE s.id_usuario = ?`,
      [req.params.id],
    );
    res.json(rows);
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error al obtener solicitudes", error: error.message });
  }
};

// GET /usuarios/:id/historial
export const getHistorialByUsuario = async (req, res) => {
  try {
    const [prestamos] = await db.query(
      `SELECT p.*, e.codigo_ejemplar, l.titulo FROM prestamos p
       JOIN ejemplares_libro e ON p.id_ejemplar = e.id_ejemplar
       JOIN libros l ON e.id_libro = l.id_libro
       WHERE p.id_usuario = ?`,
      [req.params.id],
    );
    const [devoluciones] = await db.query(
      `SELECT d.*, p.id_ejemplar, l.titulo FROM devoluciones d
       JOIN prestamos p ON d.id_prestamo = p.id_prestamo
       JOIN ejemplares_libro e ON p.id_ejemplar = e.id_ejemplar
       JOIN libros l ON e.id_libro = l.id_libro
       WHERE p.id_usuario = ?`,
      [req.params.id],
    );
    res.json({ prestamos, devoluciones });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error al obtener historial", error: error.message });
  }
};
