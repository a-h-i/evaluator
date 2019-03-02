
const {pool} = require('./pool');

function Query(tableName) {
  this.tableName = tableName;
  this.where = {};
}


Query.prototype.addWhereParams = function(params) {
  Object.assign(this.where, params);
}

Query.prototype.whereSql = function() {
  const keys = Object.keys(this.where).sort();
  return keys.reduce((sql, value, index) =>{ 
    return sql + value + ' = $' + index + ' '; 
  }, '');
}

Query.prototype.whereValues = function() {
  return Object.keys(this.where).sort().map(function(key) {
    return this.where[key];
  });
}

Query.prototype.execute = function() {
  const sql = 'SELECT * FROM ' + this.tableName + this.whereSql();
  const queryOpts = {

  };

  if(Object.keys(this.where).length > 0) {
    sql += this.whereSql();
    queryOpts.values = this.whereValues()
  }
  if(this.limit) {
    sql += ' LIMIT ' + this.limit;
  }
  queryOpts.text = sql;
  return pool.query(queryOpts).then((res) => {
    if(this.transformFunction) {
      return res.rows.map(this.transformFunction);
    } else { 
      return res.rows;
    }
  });
}

module.exports = Query;