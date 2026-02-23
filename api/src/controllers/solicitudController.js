import db from "../config/database.js";

// GET /solicitudes (con filtro opcional por estado)
export const getSolicitudes = async (req, res) => {
  try {
    const { estado } = req.query;

    let query = `
      SELECT s.*, u.nombre, u.apellido, l.titulo
      FROM solicitudes_prestamo s
      JOIN usuarios u ON s.id_usuario = u.id_usuario
      JOIN libros l ON s.id_libro = l.id_libro
      WHERE 1=1
    `;

    let params = [];

    if (estado) {
      query += " AND s.estado = ?";
      params.push(estado);
    }

    const [rows] = await db.query(query, params);
    res.json(rows);

  } catch (error) {
    res.status(500).json({
      message: "Error al obtener solicitudes",
      error: error.message
    });
  }
};

// GET /solicitudes/:id
export const getSolicitudById = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT s.*, u.nombre, u.apellido, l.titulo
       FROM solicitudes_prestamo s
       JOIN usuarios u ON s.id_usuario = u.id_usuario
       JOIN libros l ON s.id_libro = l.id_libro
       WHERE s.id_solicitud = ?`,
      [req.params.id]
    );

    if (rows.length === 0)
      return res.status(404).json({ message: "Solicitud no encontrada" });

    res.json(rows[0]);

  } catch (error) {
    res.status(500).json({
      message: "Error al obtener solicitud",
      error: error.message
    });
  }
};

// POST /solicitudes
export const createSolicitud = async (req, res) => {
  const { id_usuario, id_libro } = req.body;

  try {
    const [result] = await db.query(
      `INSERT INTO solicitudes_prestamo
       (id_usuario, id_libro, fecha_solicitud, estado)
       VALUES (?, ?, CURRENT_DATE, 'pendiente')`,
      [id_usuario, id_libro]
    );

    res.status(201).json({
      message: "Solicitud creada",
      id_solicitud: result.insertId
    });

  } catch (error) {
    res.status(500).json({
      message: "Error al crear solicitud",
      error: error.message
    });
  }
};

// PUT /solicitudes/:id/estado
export const updateEstadoSolicitud = async (req, res) => {
  const { estado } = req.body;

  try {
    // Obtener datos de la solicitud antes de actualizar
    const [[solicitud]] = await db.query(
      `SELECT * FROM solicitudes_prestamo WHERE id_solicitud = ?`,
      [req.params.id]
    );

    if (!solicitud)
      return res.status(404).json({ message: "Solicitud no encontrada" });

    // Actualizar estado
    await db.query(
      `UPDATE solicitudes_prestamo SET estado = ? WHERE id_solicitud = ?`,
      [estado, req.params.id]
    );

    let id_prestamo = null;

    // Si se aprueba, crear préstamo automáticamente
    if (estado === 'aprobada') {
      // Buscar un ejemplar disponible del libro solicitado
      const [ejemplares] = await db.query(
        `SELECT id_ejemplar FROM ejemplares_libro
         WHERE id_libro = ? AND disponibilidad = 'disponible'
         LIMIT 1`,
        [solicitud.id_libro]
      );

      if (ejemplares.length === 0) {
        return res.status(400).json({
          message: "No hay ejemplares disponibles para este libro"
        });
      }

      const id_ejemplar = ejemplares[0].id_ejemplar;

      // Crear el préstamo (15 días por defecto)
      const [prestamo] = await db.query(
        `INSERT INTO prestamos
         (id_usuario, id_ejemplar, id_solicitud, fecha_prestamo, fecha_devolucion, estado)
         VALUES (?, ?, ?, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 15 DAY), 'activo')`,
        [solicitud.id_usuario, id_ejemplar, req.params.id]
      );

      // Marcar ejemplar como prestado
      await db.query(
        `UPDATE ejemplares_libro SET disponibilidad = 'prestado' WHERE id_ejemplar = ?`,
        [id_ejemplar]
      );

      id_prestamo = prestamo.insertId;
    }

    res.json({
      message: "Estado actualizado correctamente",
      ...(id_prestamo && { id_prestamo })
    });

  } catch (error) {
    res.status(500).json({
      message: "Error al actualizar estado",
      error: error.message
    });
  }
};
