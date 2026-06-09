## Checklist de Avance - Proyecto Integrador (Parte 2)

### A. Abstracción y Lógica Procedural

- [x] **1.** Categorizar correctamente la volatilidad de la función (`IMMUTABLE`, `STABLE` o `VOLATILE`) analizando el consumo de CPU.

- [x] **2.** Diseñar el procedimiento almacenado principal para la tarea compleja de negocio.

- [x] **3.** Implementar la robustez de tipos en variables usando `%TYPE`, `%ROWTYPE` o `RECORD` (evitar tipos estáticos).



###  B. Gestión Avanzada de Transacciones

- [ ] **1.** Asegurar la atomicidad global del procedimiento mediante sentencias explícitas de `COMMIT` y `ROLLBACK`.

- [ ] **2.** Identificar el subproceso secundario propenso a fallas y aislarlo mediante la declaración de un `SAVEPOINT`.

- [ ] **3.** Implementar la lógica de reversión parcial (`ROLLBACK TO SAVEPOINT`) ante un error controlado.



### C. Capa de Auditoría y Forense de Datos

- [x] **1.** Crear la tabla física `audit_logs` con los campos necesarios para metadatos del sistema.

- [x] **2.** Implementar bloques estructurados `EXCEPTION` en los puntos críticos de los scripts.

- [ ] **3.** Utilizar `GET STACKED DIAGNOSTICS` para extraer de forma limpia el `RETURNED_SQLSTATE` y el `MESSAGE_TEXT`.



### D. Seguridad y Blindaje (Hardening)

- [x] **1.** Configurar la cabecera del proceso administrativo crítico bajo el contexto de `SECURITY DEFINER`.

- [x] **2.** Blindar las funciones restringiendo el vector de ataque mediante la fijación explícita del parámetro `search_path`.



### E. Automatización con Triggers

- [x] **1.** Definir la tabla objetivo y la sincronización temporal del disparador (`BEFORE` / `AFTER`).

- [x] **2.** Crear la función asociada al disparador aplicando lógica condicional mediante las pseudovariables `OLD` y `NEW`.

- [x] **3.** Ejecutar la sentencia `CREATE TRIGGER` y verificar la reactividad ante eventos DML (INSERT, UPDATE o DELETE).

---

### parte 3

Este proyecto implementa un sistema de gestión logística con base de datos relacional en PostgreSQL y una capa de caché en memoria utilizando Redis.

El objetivo principal es optimizar el rendimiento de consultas frecuentes mediante el patrón Cache-Aside (Lazy Loading), reduciendo la carga sobre la base de datos principal.

Tecnologías utilizadas
Node.js
Express.js
PostgreSQL
Redis (Docker)
pg (cliente PostgreSQL)
redis (cliente Node.js)

El sistema sigue el patrón:

El backend recibe una solicitud
Busca el dato en Redis
Si existe (CACHE HIT) → responde inmediatamente
Si no existe (CACHE MISS):
consulta PostgreSQL
guarda resultado en Redis
devuelve respuesta al cliente
