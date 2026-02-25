# Biblioteca-escolar
Sistema de gestión de biblioteca escolar con frontend en Flutter y backend en Node.js, usando MySQL para el control de libros, ejemplares, préstamos y devoluciones.

---

## Autenticación

El sistema usa **JWT (JSON Web Token)** para proteger el acceso. A continuación se describe el flujo completo, desde la pantalla de login hasta la sesión activa.

---

### Backend (`api/`)

El backend es una API REST construida con **Node.js + Express**.

#### Endpoints de autenticación

| Método | Ruta | Descripción |
|--------|------|-------------|
| `POST` | `/auth/login` | Inicia sesión y devuelve un token JWT |
| `PUT` | `/auth/change-password` | Cambia la contraseña del usuario |

#### `POST /auth/login`

**Archivo:** `api/src/controllers/authController.js`

1. Recibe `documento` y `contrasena` en el cuerpo de la petición.
2. Consulta la base de datos **uniendo las tablas `usuarios` y `login`** filtrando por `documento`.
3. Si no existe el usuario, responde con `401 – Usuario o contraseña incorrectos`.
4. Compara la contraseña enviada con el hash almacenado usando **bcryptjs** (también acepta contraseñas en texto plano para migración).
5. Si la contraseña es incorrecta, responde con `401`.
6. Si es correcta, genera un **token JWT** firmado con `JWT_SECRET` (variable de entorno), con una expiración de **8 horas**. El payload contiene:
   - `id` → `id_usuario`
   - `tipo` → `tipo_usuario` (rol del usuario)
7. Responde con `200` devolviendo:
   ```json
   {
     "token": "<jwt>",
     "usuario": {
       "id": 1,
       "nombre": "...",
       "apellido": "...",
       "tipo_usuario": "estudiante | profesor | administrador | bibliotecario"
     }
   }
   ```

#### `PUT /auth/change-password`

1. Recibe `documento`, `contrasena_actual` y `contrasena_nueva`.
2. Verifica que la contraseña actual coincida con el hash almacenado.
3. Genera un nuevo hash con **bcrypt (salt 10)** y actualiza la tabla `login`.

#### Rutas registradas

En `api/src/app.js` las rutas de autenticación se montan bajo el prefijo `/auth`:

```js
app.use("/auth", authRoutes);
```

---

### Frontend (`app_flutter/`)

El frontend es una aplicación **Flutter** que se comunica con la API mediante HTTP.

#### Capas involucradas

```
LoginScreen  →  AuthService  →  ApiClient  →  API REST
                     ↓
              SessionProvider  (estado global de sesión)
```

#### `ApiClient` (`lib/services/api_client.dart`)

Centraliza todas las peticiones HTTP:

- Almacena la **URL base** (`http://localhost:3000`).
- Guarda el token JWT en memoria (`_token`).
- Añade automáticamente el header `Authorization: Bearer <token>` a cada petición cuando hay sesión activa.
- Métodos disponibles: `get`, `post`, `put`, `delete`.

#### `AuthService` (`lib/services/auth_service.dart`)

Servicio de autenticación que usa `ApiClient`:

1. **`login(documento, contrasena)`** → hace un `POST /auth/login` con las credenciales.
   - Si el servidor devuelve `200`, extrae el token y lo guarda en `ApiClient.setToken()`.
   - Retorna `{ success: true, id, nombre, rol, token }`.
   - Si hay error, retorna `{ success: false, error: '...' }`.
2. **`logout()`** → llama a `ApiClient.clearToken()` para eliminar el token de memoria.

#### `SessionProvider` (`lib/providers/session_provider.dart`)

`ChangeNotifier` que mantiene el **estado global de la sesión** accesible desde cualquier widget:

| Propiedad | Descripción |
|-----------|-------------|
| `isAuthenticated` | `true` si hay sesión activa |
| `userName` | Nombre del usuario |
| `userRole` | Rol: `estudiante`, `profesor`, `administrador`, `bibliotecario` |
| `token` | JWT activo |
| `userId` | ID del usuario |
| `isAdmin` / `isBibliotecario` / `isGestor` / `isEstudiante` / `isProfesor` | Atajos de rol |

- **`login(...)`** → guarda los datos y llama a `notifyListeners()`.
- **`logout()`** → limpia todos los campos y notifica a los listeners.

#### `LoginScreen` (`lib/screens/login_screen.dart`)

Pantalla de inicio de sesión:

1. El usuario ingresa su **documento** y **contraseña**.
2. Al pulsar *Ingresar*, se llama a `AuthService.login()`.
3. Si el login es exitoso, se invoca `SessionProvider.login()` con los datos del usuario.
4. La navegación depende del **rol**:
   - `estudiante` o `profesor` → `StudentDashboard`
   - `administrador` o `bibliotecario` → `AdminDashboard`
5. Si hay error, se muestra un mensaje en pantalla.

---

### Flujo completo de autenticación

```
[Usuario] → escribe documento + contraseña en LoginScreen
    ↓
[AuthService.login()] → POST /auth/login  {documento, contrasena}
    ↓
[Backend authController]
  1. Busca usuario por documento en BD (JOIN usuarios + login)
  2. Verifica contraseña con bcrypt
  3. Genera JWT (payload: id, tipo_usuario; exp: 8h)
  4. Responde con token + datos del usuario
    ↓
[AuthService] → guarda token en ApiClient
[SessionProvider.login()] → actualiza estado global
    ↓
[LoginScreen] → navega al dashboard según el rol
    ↓
[Peticiones posteriores] → ApiClient adjunta "Authorization: Bearer <token>"
    en cada request para acceder a rutas protegidas
```
