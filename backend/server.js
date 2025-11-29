const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const { PrismaClient } = require('@prisma/client');
const multer = require('multer');
const path = require('path');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

// Initialize Stripe (Use a placeholder key if env not set)
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

// Prisma 7 reads DATABASE_URL from prisma.config.ts automatically
const prisma = new PrismaClient();

// Configure multer for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
    fileFilter: (req, file, cb) => {
        const filetypes = /jpeg|jpg|png|gif|webp/;
        const mimetype = filetypes.test(file.mimetype);
        const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
        if (mimetype && extname) {
            return cb(null, true);
        }
        cb(new Error('Only image files are allowed!'));
    }
});

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads')); // Serve uploaded files

// --- Auth Routes ---

app.post('/auth/register', async (req, res) => {
    const { email, password, name, role } = req.body;
    try {
        const user = await prisma.user.create({
            data: {
                email,
                password,
                name,
                role: role || 'CLIENT',
                bio: req.body.bio || '',
                skills: req.body.skills || '',
                hourlyRate: req.body.hourlyRate ? parseFloat(req.body.hourlyRate) : null,
                profileImage: req.body.profileImage || ''
            }, // In real app, hash password!
        });
        res.json(user);
    } catch (e) {
        res.status(400).json({ error: 'User already exists or invalid data' });
    }
});

app.post('/auth/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const user = await prisma.user.findUnique({ where: { email } });
        if (user && user.password === password) { // In real app, compare hash!
            res.json(user);
        } else {
            res.status(401).json({ error: 'Invalid credentials' });
        }
    } catch (e) {
        res.status(500).json({ error: 'Login failed' });
    }
});

app.put('/users/:id', async (req, res) => {
    const { id } = req.params;
    const { bio, skills, hourlyRate, profileImage } = req.body;
    try {
        const user = await prisma.user.update({
            where: { id: parseInt(id) },
            data: {
                bio,
                skills,
                hourlyRate: hourlyRate ? parseFloat(hourlyRate) : null,
                profileImage
            }
        });
        res.json(user);
    } catch (e) {
        console.error(e);
        res.status(500).json({ error: 'Failed to update profile' });
    }
});

// --- Photo Upload Route ---

app.post('/upload', upload.single('photo'), (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }
        const photoUrl = `/uploads/${req.file.filename}`;
        res.json({ photoUrl });
    } catch (e) {
        console.error(e);
        res.status(500).json({ error: 'File upload failed' });
    }
});

// --- Job Routes ---

app.post('/jobs', upload.array('photos', 5), async (req, res) => {
    const { title, description, price, latitude, longitude, clientId, category, zipCode, scheduledDate, tags } = req.body;
    const jobPhotos = req.files ? req.files.map(f => f.filename).join(',') : '';
    try {
        // const { latitude, longitude } = await geocodeZipCode(zipCode); // This line is commented out or removed as latitude/longitude are now expected in req.body
        const job = await prisma.job.create({
            data: {
                title,
                description,
                price: parseFloat(price),
                clientId: parseInt(clientId),
                zipCode,
                latitude: parseFloat(latitude),
                longitude: parseFloat(longitude),
                category,
                tags,
                isUrgent: req.body.isUrgent === 'true' || req.body.isUrgent === true,
                photos: jobPhotos,
                scheduledDate: scheduledDate ? new Date(scheduledDate) : null
            }
        });
        res.json(job);
    } catch (e) {
        console.error(e);
        res.status(500).json({ error: 'Failed to create job', details: e.message });
    }
});

app.get('/jobs', async (req, res) => {
    try {
        const jobs = await prisma.job.findMany({
            where: { status: 'OPEN' },
            include: { client: true },
        });
        res.json(jobs);
    } catch (e) {
        res.status(500).json({ error: 'Failed to fetch jobs' });
    }
});

app.get('/jobs/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const job = await prisma.job.findUnique({
            where: { id: parseInt(id) },
            include: { client: true, applications: true, provider: true },
        });
        res.json(job);
    } catch (e) {
        res.status(500).json({ error: 'Failed to fetch job' });
    }
});

app.post('/jobs/:id/accept', async (req, res) => {
    const { id } = req.params;
    const { providerId } = req.body;
    try {
        const job = await prisma.job.update({
            where: { id: parseInt(id) },
            data: {
                status: 'IN_PROGRESS',
                providerId: parseInt(providerId)
            }
        });
        res.json(job);
    } catch (e) {
        res.status(500).json({ error: 'Failed to accept provider' });
    }
});

app.patch('/jobs/:id/status', async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;
    try {
        const job = await prisma.job.update({
            where: { id: parseInt(id) },
            data: { status }
        });
        res.json(job);
    } catch (e) {
        res.status(500).json({ error: 'Failed to update status' });
    }
});

// --- Review Routes ---

app.post('/reviews', async (req, res) => {
    const { jobId, reviewerId, revieweeId, rating, comment } = req.body;
    try {
        const review = await prisma.review.create({
            data: {
                jobId: parseInt(jobId),
                reviewerId: parseInt(reviewerId),
                revieweeId: parseInt(revieweeId),
                rating: parseInt(rating),
                comment
            }
        });

        // Update stats for the person being reviewed
        await updateProviderStats(parseInt(revieweeId));

        res.json(review);
    } catch (e) {
        console.error(e);
        res.status(500).json({ error: 'Failed to create review' });
    }
});

app.get('/users/:id/reviews', async (req, res) => {
    const { id } = req.params;
    try {
        const reviews = await prisma.review.findMany({
            where: { revieweeId: parseInt(id) },
            include: { reviewer: { select: { name: true, profileImage: true } } },
            orderBy: { createdAt: 'desc' }
        });
        res.json(reviews);
    } catch (e) {
        res.status(500).json({ error: 'Failed to fetch reviews' });
    }
});

// --- Saved Jobs Routes ---

app.post('/saved-jobs', async (req, res) => {
    const { userId, jobId } = req.body;
    try {
        const existing = await prisma.savedJob.findUnique({
            where: { userId_jobId: { userId: parseInt(userId), jobId: parseInt(jobId) } }
        });

        if (existing) {
            await prisma.savedJob.delete({ where: { id: existing.id } });
            res.json({ saved: false });
        } else {
            await prisma.savedJob.create({
                data: { userId: parseInt(userId), jobId: parseInt(jobId) }
            });
            res.json({ saved: true });
        }
    } catch (e) {
        console.error(e);
        res.status(500).json({ error: 'Failed to toggle saved job' });
    }
});

app.get('/saved-jobs/:userId', async (req, res) => {
    const { userId } = req.params;
    try {
        const savedJobs = await prisma.savedJob.findMany({
            where: { userId: parseInt(userId) },
            select: { jobId: true }
        });
        res.json(savedJobs.map(s => s.jobId));
    } catch (e) {
        res.status(500).json({ error: 'Failed to fetch saved jobs' });
    }
});

// --- Notification Routes ---

app.get('/notifications/:userId', async (req, res) => {
    const { userId } = req.params;
    try {
        const notifications = await prisma.notification.findMany({
            where: { userId: parseInt(userId) },
            orderBy: { createdAt: 'desc' }
        });
        res.json(notifications);
    } catch (e) {
        res.status(500).json({ error: 'Failed to fetch notifications' });
    }
});

app.post('/notifications/:id/read', async (req, res) => {
    const { id } = req.params;
    try {
        await prisma.notification.update({
            where: { id: parseInt(id) },
            data: { read: true }
        });
        res.json({ success: true });
    } catch (e) {
        res.status(500).json({ error: 'Failed to mark as read' });
    }
});

// Helper to create notification
async function createNotification(userId, message, type, relatedId) {
    try {
        await prisma.notification.create({
            data: {
                userId,
                message,
                type,
                relatedId,
                read: false
            }
        });
        // Real-time emit
        io.to(userId).emit('notification', { message, type, relatedId });
    } catch (e) {
        console.error('Failed to create notification', e);
    }
}

// --- Application & Payment Routes ---

app.post('/jobs/:id/apply', async (req, res) => {
    const { id } = req.params;
    const { providerId } = req.body;
    try {
        const application = await prisma.application.create({
            data: {
                jobId: parseInt(id),
                providerId: parseInt(providerId),
            },
        });
        res.json(application);
    } catch (e) {
        res.status(500).json({ error: 'Failed to apply' });
    }
});

app.post('/applications/:id/accept', async (req, res) => {
    const { id } = req.params;
    try {
        // 1. Update application status
        const application = await prisma.application.update({
            where: { id: parseInt(id) },
            data: { status: 'ACCEPTED' },
            include: { job: true },
        });

        // 2. Update job status
        await prisma.job.update({
            where: { id: application.jobId },
            data: { status: 'IN_PROGRESS' },
        });

        res.json(application);
    } catch (e) {
        res.status(500).json({ error: 'Failed to accept application' });
    }
});

app.post('/create-payment-intent', async (req, res) => {
    console.log('Payment Body:', req.body);
    const { jobId, amount } = req.body;
    try {
        const paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(amount * 100), // cents
            currency: 'usd',
            metadata: { jobId: jobId.toString() }
        });
        res.json({
            clientSecret: paymentIntent.client_secret
        });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

app.post('/jobs/:id/complete', async (req, res) => {
    const { id } = req.params;
    const { providerId } = req.body; // In real app, get from auth/context

    try {
        const job = await prisma.job.findUnique({ where: { id: parseInt(id) } });

        if (!job) return res.status(404).json({ error: "Job not found" });

        // Calculate fees
        const amount = job.price;
        const platformFee = amount * 0.10;
        const providerAmount = amount - platformFee;

        // 1. Create Transaction Record
        const transaction = await prisma.transaction.create({
            data: {
                amount,
                platformFee,
                providerAmount,
                jobId: job.id,
                payerId: job.clientId,
                payeeId: parseInt(providerId)
            }
        });

        // 2. Mark Job as Completed
        const updatedJob = await prisma.job.update({
            where: { id: job.id },
            data: { status: 'COMPLETED' }
        });

        // 3. Update Provider Stats
        await updateProviderStats(parseInt(providerId));

        res.json({ job: updatedJob, transaction });

    } catch (e) {
        console.error(e);
        res.status(500).json({ error: "Failed to complete job" });
    }
});

// Helper to update provider stats (Elite status)
async function updateProviderStats(providerId) {
    try {
        // 1. Count completed jobs
        const jobsCompleted = await prisma.job.count({
            where: {
                providerId: providerId,
                status: 'COMPLETED'
            }
        });

        // 2. Calculate average rating
        const reviews = await prisma.review.findMany({
            where: { revieweeId: providerId },
            select: { rating: true }
        });

        let averageRating = 0;
        if (reviews.length > 0) {
            const sum = reviews.reduce((acc, curr) => acc + curr.rating, 0);
            averageRating = sum / reviews.length;
        }

        // 3. Determine Elite Status
        // Criteria: 10+ jobs, 4.8+ rating
        const isElite = jobsCompleted >= 10 && averageRating >= 4.8;

        // 4. Update User
        await prisma.user.update({
            where: { id: providerId },
            data: {
                jobsCompleted,
                averageRating,
                isElite
            }
        });
        console.log(`Updated provider ${providerId}: Jobs=${jobsCompleted}, Rating=${averageRating}, Elite=${isElite}`);

    } catch (e) {
        console.error("Failed to update provider stats:", e);
    }
}


// --- Socket.io ---

io.on('connection', (socket) => {
    console.log('A user connected:', socket.id);

    socket.on('join_room', (userId) => {
        socket.join(userId);
    });

    socket.on('send_message', async (data) => {
        try {
            const message = await prisma.message.create({
                data: {
                    senderId: data.senderId,
                    receiverId: data.receiverId,
                    content: data.content
                }
            });
            io.to(data.receiverId).emit('receive_message', message);
            io.to(data.senderId).emit('receive_message', message);
        } catch (e) {
            console.error("Error sending message:", e);
        }
    });

    socket.on('disconnect', () => {
        console.log('User disconnected:', socket.id);
    });
});

// --- Message Routes ---

app.get('/conversations/:userId', async (req, res) => {
    const { userId } = req.params;
    const id = parseInt(userId);
    try {
        // Find all messages where user is sender or receiver
        const messages = await prisma.message.findMany({
            where: {
                OR: [{ senderId: id }, { receiverId: id }]
            },
            include: { sender: true, receiver: true },
            orderBy: { createdAt: 'desc' }
        });

        // Extract unique contacts
        const contacts = new Map();
        messages.forEach(msg => {
            const otherUser = msg.senderId === id ? msg.receiver : msg.sender;
            if (!contacts.has(otherUser.id)) {
                contacts.set(otherUser.id, {
                    user: otherUser,
                    lastMessage: msg.content,
                    timestamp: msg.createdAt
                });
            }
        });

        res.json(Array.from(contacts.values()));
    } catch (e) {
        console.error(e);
        res.status(500).json({ error: 'Failed to fetch conversations' });
    }
});

app.get('/messages/:userId/:otherUserId', async (req, res) => {
    const { userId, otherUserId } = req.params;
    try {
        const messages = await prisma.message.findMany({
            where: {
                OR: [
                    { senderId: parseInt(userId), receiverId: parseInt(otherUserId) },
                    { senderId: parseInt(otherUserId), receiverId: parseInt(userId) }
                ]
            },
            orderBy: { createdAt: 'asc' }
        });
        res.json(messages);
    } catch (e) {
        res.status(500).json({ error: 'Failed to fetch messages' });
    }
});

const PORT = process.env.PORT || 3000;

if (require.main === module) {
    server.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
    });
}

module.exports = app;
