import db from "../config/database.js";

// GET /ejemplares
export const getEjemplares = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT e.*, l.titulo
       FROM ejemplares_libro e
       JOIN libros l ON e.id_libro = l.id_libro`
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({
      message: "Error al obtener ejemplares",
      error: error.message
    });
  }
};

// GET /ejemplares/:id
export const getEjemplarById = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT e.*, l.titulo
       FROM ejemplares_libro e
       JOIN libros l ON e.id_libro = l.id_libro
       WHERE e.id_ejemplar = ?`,
      [req.params.id]
    );

    if (rows.length === 0)
      return res.status(404).json({ message: "Ejemplar no encontrado" });

    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({
      message: "Error al obtener ejemplar",
      error: error.message
    });
  }
};

// GET /libros/:id/ejemplares
export const getEjemplaresByLibro = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT * FROM ejemplares_libro WHERE id_libro = ?`,
      [req.params.id]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({
      message: "Error al obtener ejemplares del libro",
      error: error.message
    });
  }
};

// GET /libros/:id/disponibilidad
export const getDisponibilidadLibro = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT 
         COUNT(*) AS total,
         SUM(disponibilidad = 'disponible') AS disponibles,
         SUM(disponibilidad = 'prestado') AS prestados,
         SUM(disponibilidad = 'mantenimiento') AS mantenimiento
       FROM ejemplares_libro
       WHERE id_libro = ?`,
      [req.params.id]
    );

    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({
      message: "Error al obtener disponibilidad",
      error: error.message
    });
  }
};

// POST /ejemplares
export const createEjemplar = async (req, res) => {
  const { id_libro, codigo_ejemplar, condicion_fisica, disponibilidad } = req.body;

  try {
    // Si no se envía código, generar uno automático basado en el máximo global
    let codigoFinal = codigo_ejemplar;
    if (!codigoFinal) {
      const [rows] = await db.query(
        `SELECT codigo_ejemplar FROM ejemplares_libro 
         WHERE codigo_ejemplar LIKE 'EJ-%' 
         ORDER BY CAST(SUBSTRING(codigo_ejemplar, 4) AS UNSIGNED) DESC 
         LIMIT 1`
      );
      let nextNum = 1;
      if (rows.length > 0) {
        const lastCode = rows[0].codigo_ejemplar;
        const num = parseInt(lastCode.replace('EJ-', ''), 10);
        if (!isNaN(num)) nextNum = num + 1;
      }
      codigoFinal = `EJ-${String(nextNum).padStart(3, '0')}`;
    }

    const [result] = await db.query(
      `INSERT INTO ejemplares_libro 
       (id_libro, codigo_ejemplar, condicion_fisica, disponibilidad)
       VALUES (?, ?, ?, ?)`,
      [
        id_libro,
        codigoFinal,
        condicion_fisica || "bueno",
        disponibilidad || "disponible"
      ]
    );

    res.status(201).json({
      message: "Ejemplar creado",
      id_ejemplar: result.insertId,
      codigo_ejemplar: codigoFinal
    });

  } catch (error) {
    res.status(500).json({
      message: "Error al crear ejemplar",
      error: error.message
    });
  }
};

// PUT /ejemplares/:id
export const updateEjemplar = async (req, res) => {
  const { id_libro, codigo_ejemplar, condicion_fisica, disponibilidad } = req.body;

  try {
    const [result] = await db.query(
      `UPDATE ejemplares_libro
       SET id_libro=?, codigo_ejemplar=?, condicion_fisica=?, disponibilidad=?
       WHERE id_ejemplar=?`,
      [
        id_libro,
        codigo_ejemplar,
        condicion_fisica,
        disponibilidad,
        req.params.id
      ]
    );

    if (result.affectedRows === 0)
      return res.status(404).json({ message: "Ejemplar no encontrado" });

    res.json({ message: "Ejemplar actualizado" });

  } catch (error) {
    res.status(500).json({
      message: "Error al actualizar ejemplar",
      error: error.message
    });
  }
};

// DELETE /ejemplares/:id
export const deleteEjemplar = async (req, res) => {
  try {
    const [result] = await db.query(
      "DELETE FROM ejemplares_libro WHERE id_ejemplar = ?",
      [req.params.id]
    );

    if (result.affectedRows === 0)
      return res.status(404).json({ message: "Ejemplar no encontrado" });

    res.json({ message: "Ejemplar eliminado" });

  } catch (error) {
    res.status(500).json({
      message: "Error al eliminar ejemplar",
      error: error.message
    });
  }
};
