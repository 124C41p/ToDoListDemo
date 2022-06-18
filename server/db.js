const { Pool } = require('pg')
const pool = new Pool()

module.exports = {
  init: () => pool.query(`
      CREATE TABLE IF NOT EXISTS todo_list(
        id serial PRIMARY KEY,
        text TEXT
      )
    `),
  add: text => pool.query('INSERT INTO todo_list(text) VALUES($1)', [text]),
  remove: id => pool.query('DELETE FROM todo_list WHERE id = $1', [id]),
  getList: async () => (await pool.query('SELECT * FROM todo_list')).rows
}