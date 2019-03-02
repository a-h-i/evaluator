

exports.LISTEN_PORT = process.env.EV_WS_PORT || '4000';
exports.REDIS_HOST = process.env.EVALUATOR_REDIS_MESSAGING_HOST || 'localhost';
exports.REDIS_PORT = process.env.EVALUATOR_REDIS_MESSAGING_PORT || '6379';

exports.keys = require('../keys.json');