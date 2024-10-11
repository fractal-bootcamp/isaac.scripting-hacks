#!/bin/bash

echo "This script will help you set up a Vite/React/TypeScript frontend and a basic Bun/Express backend."

# Input for the project directory
read -p "Enter the name for the new directory: " dirName

if [ -z "$dirName" ]; then
    echo "Directory name cannot be empty. Exiting."
    exit 1
fi

# Create the new directory
mkdir -p "$dirName" || { echo "Error creating directory"; exit 1; }

# Change to the new directory
cd "$dirName" || { echo "Error changing to new directory"; exit 1; }

# Frontend setup: Vite with React and TypeScript
echo "Setting up frontend with Vite/React/TypeScript..."
mkdir frontend
cd frontend
bun create vite . --template react-ts

if [ $? -ne 0 ]; then
    echo "Error initializing frontend project."
    exit 1
fi

# Install frontend dependencies
bun install

if [ $? -ne 0 ]; then
    echo "Error during bun install for frontend."
    exit 1
fi

# Backend setup: Basic Bun project with Express and CORS
echo "Setting up backend with Bun/Express..."
cd ..
mkdir backend
cd backend
bun init -y

if [ $? -ne 0 ]; then
    echo "Error initializing backend project."
    exit 1
fi

# Install backend dependencies (Express, CORS)
bun add express cors dotenv

if [ $? -ne 0 ]; then
    echo "Error installing backend dependencies."
    exit 1
fi

# Create basic server file
cat > index.ts << EOL
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.send('Hello, world!');
});

app.listen(port, () => {
  console.log(\`Server is running on http://localhost:\${port}\`);
});
EOL

echo "Backend setup complete!"

# Capture current working directory paths for frontend and backend
frontendDir="$PWD/../frontend"
backendDir="$PWD"

# Run the frontend and backend servers in separate terminal tabs on macOS
echo "Starting both frontend and backend servers..."

# Start frontend in a new terminal tab
osascript -e 'tell application "Terminal"
    do script "cd '$frontendDir' && bun run dev"
end tell'

# Start backend in a new terminal tab
osascript -e 'tell application "Terminal"
    do script "cd '$backendDir' && bun run index.ts"
end tell'

echo "Frontend and backend servers are now running."
