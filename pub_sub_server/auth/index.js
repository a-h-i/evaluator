const subscriptions = require('./subscription-handlers');

exports.handleSubscribe = subscriptions.handleSubscribe;
exports.handleUnsubscribe = subscriptions.handleUnsubscribe;



exports.registerHandlers = function(socket) {
  socket.on('subcribe', handleSubscribe.bind(null, socket));
  socket.on('unsubscribe', handleUnsubscribe.bind(null, socket));
}