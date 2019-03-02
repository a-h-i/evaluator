const { Pool } = require('pg').native;
const {database, db_host, db_user, db_password, db_port, db_max_pool, db_min_pool} = require('../config');



var singleton;

Object.defineProperty(singleton, 'pool', {
  get: function() {
    if(!global.PG_POOL) {
      global.PG_POOL = new Pool({
        database: database,
        host: db_host,
        user: db_user,
        password: db_password,
        port: db_port,
        max: db_max_pool,
        min: db_min_pool
      });
    }
    return global.PG_POOL;
  }
});


module.exports = singleton;