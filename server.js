const express = require("express");
const { Pool } = require("pg");
const { createClient } = require("redis");

const app = express();
app.use(express.json());

/* POSTGRES */
const pool = new Pool({
    user: "postgres",
    host: "localhost",
    database: "logistica",
    password: "Roma4354",
    port: 5432
});

/* REDIS */
const redis = createClient({
    url: "redis://localhost:6379"
});

(async () => {
    await redis.connect();
    console.log("Redis conectado ✔");
})();

/* ENDPOINT SIMPLE (CLIENTES) */
app.get("/clientes/:id", async (req, res) => {
    const id = req.params.id;
    const key = `clientes:${id}`;

    // 1. buscar en Redis
    const cache = await redis.get(key);

    if (cache) {
        return res.json({
            source: "redis",
            data: JSON.parse(cache)
        });
    }

    // 2. si no existe → PostgreSQL
    const result = await pool.query(
        "SELECT * FROM clientes WHERE id = $1",
        [id]
    );

    const data = result.rows[0];

    // 3. guardar en Redis 2 min
    await redis.setEx(key, 120, JSON.stringify(data));

    res.json({
        source: "postgres",
        data
    });
});

app.listen(3000, () => {
    console.log("Servidor en puerto 3000");
});