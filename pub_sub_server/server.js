const config = require('./config');
const server = require('http-shutdown')(require('http').createServer());
const redisAdapter = require('socket.io-redis');
const { registerHandlers } = require('./auth');
const {pool} = require('./db');

const io = require('socket.io')(server, {
  path: '/notifications',
  serveClient: false,
  adapter: redisAdapter({
    host: config.REDIS_HOST,
    port: config.REDIS_PORT,
    key: 'socket.io'
  }),
  transports: ['polling', 'websocket'],
  httpCompression: true,
  cookie: 'notifications',
  cookiePath: '/',
  cookieHttpOnly: true,
  wsEngine: 'uws'
});

io.on('connection', registerHandlers);



process.on('SIGTERM', () => {
  // shutdown server
  server.shutdown( async function() {
    // shutdown pg pool
    await pool.end();
  });

});


server.listen(config.LISTEN_PORT);

