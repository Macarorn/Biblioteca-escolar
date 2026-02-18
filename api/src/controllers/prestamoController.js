import db from "../config/database.js";


// GET /prestamos
export const getPrestamos = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT p.*, u.nombre, u.apellido, 
             e.codigo_ejemplar, l.titulo
      FROM prestamos p
      JOIN usuarios u ON p.id_usuario = u.id_usuario
      JOIN ejemplares_libro e ON p.id_ejemplar = e.id_ejemplar
      JOIN libros l ON e.id_libro = l.id_libro
    `);

    res.json(rows);
  } catch (error) {
    res.status(500).json({
      message: "Error al obtener préstamos",
      error: error.message
    });
  }
};


// GET /prestamos/:id
export const getPrestamoById = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT p.*, u.nombre, u.apellido, 
             e.codigo_ejemplar, l.titulo
      FROM prestamos p
      JOIN usuarios u ON p.id_usuario = u.id_usuario
      JOIN ejemplares_libro e ON p.id_ejemplar = e.id_ejemplar
      JOIN libros l ON e.id_libro = l.id_libro
      WHERE p.id_prestamo = ?
    `, [req.params.id]);

    if (rows.length === 0)
      return res.status(404).json({ message: "Préstamo no encontrado" });

    res.json(rows[0]);

  } catch (error) {
    res.status(500).json({
      message: "Error al obtener préstamo",
      error: error.message
    });
  }
};


// POST /prestamos
export const createPrestamo = async (req, res) => {
  const { id_usuario, id_ejemplar, id_solicitud, dias_prestamo } = req.body;

  try {
    const dias = dias_prestamo || 15;

    // 1️⃣ Crear préstamo con fecha de devolución estimada
    const [result] = await db.query(`
      INSERT INTO prestamos
      (id_usuario, id_ejemplar, id_solicitud, fecha_prestamo, fecha_devolucion, estado)
      VALUES (?, ?, ?, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL ? DAY), 'activo')
    `, [id_usuario, id_ejemplar, id_solicitud || null, dias]);

    // 2️⃣ Cambiar disponibilidad del ejemplar a "prestado"
    await db.query(`
      UPDATE ejemplares_libro
      SET disponibilidad = 'prestado'
      WHERE id_ejemplar = ?
    `, [id_ejemplar]);

    res.status(201).json({
      message: "Préstamo creado correctamente",
      id_prestamo: result.insertId
    });

  } catch (error) {
    res.status(500).json({
      message: "Error al crear préstamo",
      error: error.message
    });
  }
};


// PUT /prestamos/:id/estado
export const updateEstadoPrestamo = async (req, res) => {
  const { estado } = req.body;

  try {
    const [result] = await db.query(`
      UPDATE prestamos
      SET estado = ?
      WHERE id_prestamo = ?
    `, [estado, req.params.id]);

    if (result.affectedRows === 0)
      return res.status(404).json({ message: "Préstamo no encontrado" });

    // Si se devuelve el libro, actualizar disponibilidad
    if (estado === "devuelto") {
      const [[prestamo]] = await db.query(
        "SELECT id_ejemplar FROM prestamos WHERE id_prestamo = ?",
        [req.params.id]
      );

      await db.query(`
        UPDATE ejemplares_libro
        SET disponibilidad = 'disponible'
        WHERE id_ejemplar = ?
      `, [prestamo.id_ejemplar]);
    }

    res.json({ message: "Estado actualizado correctamente" });

  } catch (error) {
    res.status(500).json({
      message: "Error al actualizar estado",
      error: error.message
    });
  }
};


// GET /prestamos/vencidos
export const getPrestamosVencidos = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT p.*, u.nombre, u.apellido, l.titulo
      FROM prestamos p
      JOIN usuarios u ON p.id_usuario = u.id_usuario
      JOIN ejemplares_libro e ON p.id_ejemplar = e.id_ejemplar
      JOIN libros l ON e.id_libro = l.id_libro
      WHERE p.estado = 'activo'
        AND p.fecha_devolucion IS NOT NULL
        AND p.fecha_devolucion < CURRENT_DATE
    `);

    res.json(rows);

  } catch (error) {
    res.status(500).json({
      message: "Error al obtener préstamos vencidos",
      error: error.message
    });
  }
};
