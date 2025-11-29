const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const { PrismaClient } = require('@prisma/client');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*", // Allow all origins for mobile app
    methods: ["GET", "POST"]
  }
});

const prisma = new PrismaClient();

app.use(cors());
app.use(express.json());

// Basic Health Check
app.get('/', (req, res) => {
  res.send('Done App Backend is running');
});

// Socket.io Connection
io.on('connection', (socket) => {
  console.log('A user connected:', socket.id);

  socket.on('join_room', (userId) => {
    socket.join(userId);
    console.log(`User ${userId} joined their room`);
  });

  socket.on('send_message', async (data) => {
    // data: { senderId, receiverId, content }
    try {
        const message = await prisma.message.create({
            data: {
                senderId: data.senderId,
                receiverId: data.receiverId,
                content: data.content
            }
        });
        
        // Emit to receiver
        io.to(data.receiverId).emit('receive_message', message);
        // Emit back to sender (for confirmation/optimistic UI)
        io.to(data.senderId).emit('receive_message', message);
        
    } catch (e) {
        console.error("Error sending message:", e);
    }
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
