import app from "./app.js";

const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
  console.log(` Servidor corriendo en http://localhost:${PORT}`);
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(` Error: El puerto ${PORT} ya está en uso. Cierra la otra instancia primero.`);
  } else {
    console.error(`Error del servidor:`, err);
  }
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error(' Unhandled Rejection:', reason);
});

process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});
