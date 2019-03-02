const jwt = require('jsonwebtoken');
const config = require('../config');
const {User} = require('../db');
const {createHash} = require('crypto');
const safeCompare = require('safe-compare');

function getJWTKey(header, callback) {
  callback(null, Buffer.from(config.keys.jwt_hash_key, 'hex'))
}

exports.handleSubscribe = function(socket, data, callback) {
  token = data.token;
  jwt.verify(token, getJWTKey, {
    algorithms: ['HS512']
  }, (err, decoded) => {

    if(err) {
      return callback({
        status: false
      });
      
    }
    // Verify password digest

   user = await User.find({
      id: decoded.data.id
    }).execute();
    hash = createHash('sha512');
    hash.update(user.password_digest);

    
    // we compare the discriminator with the SHA512 of the user's password digest
    if(safeCompare(decoded.data.discriminator, hash.digest('hex'))){
      socket.join(`users${user.id}`);
      // TODO: Implement other subscription types.
      callback({
        status: true
      });

    } else {
      callback({
        status: false
      });
    }
  });
}

exports.handleUnsubscribe = function(socket, data) {
  const target = '' + data.target;
  socket.leave(target);
}