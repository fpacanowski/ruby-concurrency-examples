const net = require('net');

const delay = t => new Promise(resolve => setTimeout(resolve, t));

const server = net.createServer((socket) => {
  const randomNum = Math.floor(Math.random() * 100); // Generate random number
  delay(2000).then(() => {
    socket.write(`${randomNum}`); // Send number to client
    socket.end(); // Close the connection
  });
});

server.listen(9000, () => {
  console.log('Server listening on port 9000');
});

