CREATE DATABASE IF NOT EXISTS biblioteca_escolar;
USE biblioteca_escolar;

-- Usuarios
CREATE TABLE usuarios (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  documento VARCHAR(50) NOT NULL UNIQUE,
  tipo_usuario ENUM('estudiante','profesor','administrador','bibliotecario') 
    DEFAULT 'estudiante'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Login
CREATE TABLE login (
  id_login INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  documento VARCHAR(50) NOT NULL,
  contrasena VARCHAR(255) NOT NULL,
  FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Libros
CREATE TABLE libros (
  id_libro INT AUTO_INCREMENT PRIMARY KEY,
  codigo_libro VARCHAR(50),
  titulo VARCHAR(200) NOT NULL,
  autor VARCHAR(150),
  area VARCHAR(100),
  anio_publicacion YEAR(4),
  estado ENUM('activo','inactivo') DEFAULT 'activo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ejemplares_libro
CREATE TABLE ejemplares_libro (
  id_ejemplar INT AUTO_INCREMENT PRIMARY KEY,
  id_libro INT NOT NULL,
  codigo_ejemplar VARCHAR(50) UNIQUE,
  condicion_fisica ENUM('excelente','bueno','regular','malo') DEFAULT 'bueno',
  disponibilidad ENUM('disponible','prestado','mantenimiento') 
    DEFAULT 'disponible',
  FOREIGN KEY (id_libro) REFERENCES libros(id_libro)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- solicitudes_prestamo
CREATE TABLE solicitudes_prestamo (
  id_solicitud INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  id_libro INT NOT NULL,
  fecha_solicitud DATE NOT NULL,
  estado ENUM('pendiente','aprobada','rechazada','cancelada') 
    DEFAULT 'pendiente',
  FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
  FOREIGN KEY (id_libro) REFERENCES libros(id_libro)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- prestamos
CREATE TABLE prestamos (
  id_prestamo INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  id_ejemplar INT NOT NULL,
  id_solicitud INT NULL,
  fecha_prestamo DATE NOT NULL,
  fecha_devolucion DATE,
  estado ENUM('activo','devuelto','vencido') DEFAULT 'activo',
  FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
  FOREIGN KEY (id_ejemplar) REFERENCES ejemplares_libro(id_ejemplar),
  FOREIGN KEY (id_solicitud) REFERENCES solicitudes_prestamo(id_solicitud)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- devoluciones
CREATE TABLE devoluciones (
  id_devolucion INT AUTO_INCREMENT PRIMARY KEY,
  id_prestamo INT NOT NULL,
  fecha_devolucion DATE NOT NULL,
  observaciones TEXT,
  FOREIGN KEY (id_prestamo) REFERENCES prestamos(id_prestamo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- INSERTS DE DATOS DE PRUEBA

-- Usuarios
INSERT INTO usuarios (nombre, apellido, documento, tipo_usuario) VALUES
('Ana', 'Martínez', '1001', 'estudiante'),
('Carlos', 'Pérez', '1002', 'estudiante'),
('Laura', 'Gómez', '2001', 'profesor'),
('Miguel', 'Ríos', '3001', 'bibliotecario'),
('Admin', 'Sistema', '9999', 'administrador');

-- Login
INSERT INTO login (id_usuario, documento, contrasena) VALUES
(1, '1001', 'hash123'),
(2, '1002', 'hash123'),
(3, '2001', 'hash123'),
(4, '3001', 'hash123'),
(5, '9999', 'hash123');

-- Libros
INSERT INTO libros (codigo_libro, titulo, autor, area, anio_publicacion) VALUES
('L001', 'Cien años de soledad', 'Gabriel García Márquez', 'Literatura', 1967),
('L002', 'El principito', 'Antoine de Saint-Exupéry', 'Infantil', 1943),
('L003', 'Don Quijote de la Mancha', 'Miguel de Cervantes', 'Clásicos', 1901),
('L004', 'Harry Potter y la piedra filosofal', 'J.K. Rowling', 'Fantasía', 1997),
('L005', 'Clean Code', 'Robert C. Martin', 'Programación', 2008);


-- Ejemplares_libro
INSERT INTO ejemplares_libro (id_libro, codigo_ejemplar, condicion_fisica, disponibilidad) VALUES
(1, 'EJ-001', 'excelente', 'disponible'),
(1, 'EJ-002', 'regular', 'prestado'),
(2, 'EJ-003', 'excelente', 'disponible'),
(2, 'EJ-004', 'bueno', 'disponible'),
(3, 'EJ-005', 'regular', 'disponible'),
(3, 'EJ-006', 'bueno', 'prestado'),
(4, 'EJ-007', 'malo', 'disponible'),
(4, 'EJ-008', 'bueno', 'disponible'),
(5, 'EJ-009', 'malo', 'disponible'),
(5, 'EJ-010', 'regular', 'mantenimiento');


-- Solicitudes_prestamo
INSERT INTO solicitudes_prestamo (id_usuario, id_libro, fecha_solicitud, estado) VALUES
(1, 1, CURRENT_DATE, 'pendiente'),
(2, 4, CURRENT_DATE, 'aprobada'),
(3, 5, CURRENT_DATE, 'aprobada');

-- Prestamos
INSERT INTO prestamos (id_usuario, id_ejemplar, id_solicitud, fecha_prestamo, estado) VALUES
(2, 6, 2, CURRENT_DATE, 'activo'),
(3, 10, 3, CURRENT_DATE, 'devuelto');

-- Devoluciones
INSERT INTO devoluciones (id_prestamo, fecha_devolucion, observaciones) VALUES
(2, CURRENT_DATE, 'Libro devuelto en buen estado');



