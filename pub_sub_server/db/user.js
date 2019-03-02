const Query = require ('./query');
const TABLE_NAME = 'users';

function User(data) {
  Object.assign(this, data);
}

User.fromResult = function(resultRow) {

  return new User(resultRow);
}

User.find = async function(params) {
  var q = new Query(TABLE_NAME);
  q.transformFunction = User.fromResult;
  q.addWhereParams(params);
  q.limit = 1;
  return q;
}

module.exports = User;