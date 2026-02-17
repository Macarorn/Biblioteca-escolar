import db from "../config/database.js";


// GET /devoluciones
export const getDevoluciones = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT d.*, p.id_usuario, l.titulo
      FROM devoluciones d
      JOIN prestamos p ON d.id_prestamo = p.id_prestamo
      JOIN ejemplares_libro e ON p.id_ejemplar = e.id_ejemplar
      JOIN libros l ON e.id_libro = l.id_libro
    `);

    res.json(rows);
  } catch (error) {
    res.status(500).json({
      message: "Error al obtener devoluciones",
      error: error.message
    });
  }
};


// GET /devoluciones/:id
export const getDevolucionById = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT d.*, p.id_usuario, l.titulo
      FROM devoluciones d
      JOIN prestamos p ON d.id_prestamo = p.id_prestamo
      JOIN ejemplares_libro e ON p.id_ejemplar = e.id_ejemplar
      JOIN libros l ON e.id_libro = l.id_libro
      WHERE d.id_devolucion = ?
    `, [req.params.id]);

    if (rows.length === 0)
      return res.status(404).json({ message: "Devolución no encontrada" });

    res.json(rows[0]);

  } catch (error) {
    res.status(500).json({
      message: "Error al obtener devolución",
      error: error.message
    });
  }
};


// POST /prestamos/:id/devolver
export const devolverPrestamo = async (req, res) => {
  const { observaciones } = req.body;
  const idPrestamo = req.params.id;

  try {
    // 1️⃣ Verificar que el préstamo exista
    const [[prestamo]] = await db.query(
      "SELECT * FROM prestamos WHERE id_prestamo = ?",
      [idPrestamo]
    );

    if (!prestamo)
      return res.status(404).json({ message: "Préstamo no encontrado" });

    if (prestamo.estado === "devuelto")
      return res.status(400).json({ message: "El préstamo ya fue devuelto" });

    // 2️⃣ Insertar en devoluciones
    const [result] = await db.query(`
      INSERT INTO devoluciones
      (id_prestamo, fecha_devolucion, observaciones)
      VALUES (?, CURRENT_DATE, ?)
    `, [idPrestamo, observaciones || null]);

    // 3️⃣ Actualizar estado del préstamo
    await db.query(`
      UPDATE prestamos
      SET estado = 'devuelto'
      WHERE id_prestamo = ?
    `, [idPrestamo]);

    // 4️⃣ Cambiar disponibilidad del ejemplar
    await db.query(`
      UPDATE ejemplares_libro
      SET disponibilidad = 'disponible'
      WHERE id_ejemplar = ?
    `, [prestamo.id_ejemplar]);

    res.status(201).json({
      message: "Devolución registrada correctamente",
      id_devolucion: result.insertId
    });

  } catch (error) {
    res.status(500).json({
      message: "Error al registrar devolución",
      error: error.message
    });
  }
};
