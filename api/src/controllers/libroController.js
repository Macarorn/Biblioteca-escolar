import db from "../config/database.js";

// GET /libros (con filtros opcionales)
export const getLibros = async (req, res) => {
  try {
    const { titulo, autor, area } = req.query;

    let query = "SELECT * FROM libros WHERE 1=1";
    let params = [];

    if (titulo) {
      query += " AND titulo LIKE ?";
      params.push(`%${titulo}%`);
    }

    if (autor) {
      query += " AND autor LIKE ?";
      params.push(`%${autor}%`);
    }

    if (area) {
      query += " AND area LIKE ?";
      params.push(`%${area}%`);
    }

    const [rows] = await db.query(query, params);
    res.json(rows);

  } catch (error) {
    res.status(500).json({
      message: "Error al obtener libros",
      error: error.message
    });
  }
};

// GET /libros/:id
export const getLibroById = async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT * FROM libros WHERE id_libro = ?",
      [req.params.id]
    );

    if (rows.length === 0)
      return res.status(404).json({ message: "Libro no encontrado" });

    res.json(rows[0]);

  } catch (error) {
    res.status(500).json({
      message: "Error al obtener libro",
      error: error.message
    });
  }
};

// POST /libros
export const createLibro = async (req, res) => {
  const { codigo_libro, titulo, autor, area, anio_publicacion, estado } = req.body;

  try {
    const [result] = await db.query(
      `INSERT INTO libros (codigo_libro, titulo, autor, area, anio_publicacion, estado)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [codigo_libro, titulo, autor, area, anio_publicacion, estado || "activo"]
    );

    res.status(201).json({
      message: "Libro creado",
      id_libro: result.insertId
    });

  } catch (error) {
    res.status(500).json({
      message: "Error al crear libro",
      error: error.message
    });
  }
};

// PUT /libros/:id
export const updateLibro = async (req, res) => {
  const { codigo_libro, titulo, autor, area, anio_publicacion, estado } = req.body;

  try {
    const [result] = await db.query(
      `UPDATE libros
       SET codigo_libro=?, titulo=?, autor=?, area=?, anio_publicacion=?, estado=?
       WHERE id_libro=?`,
      [codigo_libro, titulo, autor, area, anio_publicacion, estado, req.params.id]
    );

    if (result.affectedRows === 0)
      return res.status(404).json({ message: "Libro no encontrado" });

    res.json({ message: "Libro actualizado" });

  } catch (error) {
    res.status(500).json({
      message: "Error al actualizar libro",
      error: error.message
    });
  }
};

// DELETE /libros/:id
export const deleteLibro = async (req, res) => {
  try {
    const [result] = await db.query(
      "DELETE FROM libros WHERE id_libro = ?",
      [req.params.id]
    );

    if (result.affectedRows === 0)
      return res.status(404).json({ message: "Libro no encontrado" });

    res.json({ message: "Libro eliminado" });

  } catch (error) {
    res.status(500).json({
      message: "Error al eliminar libro",
      error: error.message
    });
  }
};
