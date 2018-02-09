module.exports = {
  user: process.env.PG_USER || 'postgres',
  password: process.env.PG_PASSWORD ||'postgres',
  host: process.env.PG_HOST ||'192.168.99.100',
  database: process.env.PG_DATABASE ||'shape',
  port: process.env.PG_PORT ||5432
};