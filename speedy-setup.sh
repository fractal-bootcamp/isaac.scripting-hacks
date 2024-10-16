#!/bin/bash
echo "This script will help you set up a Vite/React/TypeScript frontend with Tailwind CSS, optional React Router, and a basic Bun/Express backend, along with an optional database."

# Input for the project directory
read -p "Enter the name for the new directory: " dirName
if [ -z "$dirName" ]; then
    echo "Directory name cannot be empty. Exiting."
    exit 1
fi

# Create the new directory
mkdir -p "$dirName" || { echo "Error creating directory"; exit 1; }
echo ""

# Change to the new directory
cd "$dirName" || { echo "Error changing to new directory"; exit 1; }
echo ""

# Frontend setup: Vite with React and TypeScript
echo "Setting up frontend with Vite/React/TypeScript..."
mkdir frontend
cd frontend
bun create vite . --template react-ts
if [ $? -ne 0 ]; then
    echo "Error initializing frontend project."
    exit 1
fi
echo ""

# Install frontend dependencies
bun install
if [ $? -ne 0 ]; then
    echo "Error during bun install for frontend."
    exit 1
fi
echo ""

# Install Tailwind CSS and its dependencies using Bun
echo "Installing Tailwind CSS..."
bun add -d tailwindcss postcss autoprefixer
if [ $? -ne 0 ]; then
    echo "Error installing Tailwind CSS."
    exit 1
fi

# Initialize Tailwind CSS configuration
bunx tailwindcss init -p
if [ $? -ne 0 ]; then
    echo "Error initializing Tailwind CSS."
    exit 1
fi

# Overwrite the Tailwind configuration file with the necessary content paths
cat > tailwind.config.js <<EOL
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOL

# Replace the content of src/index.css with Tailwind directives
cat > src/index.css <<EOL
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL

echo "Tailwind CSS has been set up successfully."
echo ""

# Ask if the user wants to install React Router
# NOTE: Selecting 'No' may give a warning because Tailwind is installed but not being used in the default template
read -p "Do you want to install React Router? (Y/N): " installReactRouter 
if [[ "$installReactRouter" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Installing React Router..."
    echo ""

    # Install react-router-dom using Bun
    bun add react-router-dom
    if [ $? -ne 0 ]; then
        echo "Error installing React Router."
        exit 1
    fi

    # Create src/pages directory
    mkdir -p src/pages

    # Create src/pages/Home.tsx
    cat > src/pages/Home.tsx <<EOL
import React from 'react';

function Home() {
  return (
    <div>
      <h2 className="text-2xl font-bold">Home Page</h2>
      <p>Welcome to the home page!</p>
    </div>
  );
}

export default Home;
EOL

    # Create src/pages/About.tsx
    cat > src/pages/About.tsx <<EOL
import React from 'react';

function About() {
  return (
    <div>
      <h2 className="text-2xl font-bold">About Page</h2>
      <p>This is the about page.</p>
    </div>
  );
}

export default About;
EOL

    # Replace the content of src/App.tsx with a component using Tailwind CSS classes and React Router
    cat > src/App.tsx <<EOL
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import Home from './pages/Home';
import About from './pages/About';

function App() {
  return (
    <Router>
      <nav className="p-4 bg-gray-200">
        <Link to="/" className="mr-4">Home</Link>
        <Link to="/about">About</Link>
      </nav>
      <div className="p-4">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
EOL

    echo "React Router has been installed and basic pages have been set up."
    echo ""
fi

# Back to the main project directory
cd ..
echo ""

# Backend setup: Basic Bun project with Express and CORS
echo "Setting up backend with Bun/Express..."
mkdir backend
cd backend
bun init -y
if [ $? -ne 0 ]; then
    echo "Error initializing backend project."
    exit 1
fi
echo ""

# Install backend dependencies (Express, CORS)
bun add express cors
if [ $? -ne 0 ]; then
    echo "Error installing backend dependencies."
    exit 1
fi
echo ""

# Install type definitions for Express and CORS
bun add -d @types/express @types/cors
if [ $? -ne 0 ]; then
    echo "Error installing type definitions."
    exit 1
fi
echo ""

# Create a basic index.ts with Express, CORS, and a simple API route
cat > index.ts << INDEX_TS_EOF
import express from 'express';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 3000;

// Apply CORS middleware
app.use(cors());

// Body parser middleware (JSON)
app.use(express.json());

// Example API route
app.get('/api', (req, res) => {
    console.log('API endpoint hit');
    res.json({ message: 'Hello from the API!' });
});

console.log("Hello from Bun!");

// Start server
app.listen(PORT, () => {
    console.log(\`Server is running on http://localhost:\${PORT}\`);
});
INDEX_TS_EOF
echo "Basic Express server setup with CORS and a sample API route has been added to index.ts."
echo ""

# Ask if the user needs a database
read -p "Do you need a Database? (Y/N): " needDatabase
if [[ "$needDatabase" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Setting up Prisma and Docker for PostgreSQL..."
    echo ""

    # Install Prisma and @prisma/client
    bun add -d prisma
    if [ $? -ne 0 ]; then
        echo "Error installing Prisma."
        exit 1
    fi
    bun add @prisma/client
    if [ $? -ne 0 ]; then
        echo "Error installing @prisma/client."
        exit 1
    fi
    echo ""

    # Initialize Prisma
    npx prisma init
    if [ $? -ne 0 ]; then
        echo "Error initializing Prisma."
        exit 1
    fi
    echo ""

    # Update DATABASE_URL in backend/.env
    cat > .env << ENV_EOF
DATABASE_URL="postgresql://postgres:postgres@localhost:5555/mydb?schema=public"
ENV_EOF
    echo ".env file created with correct DATABASE_URL"
    echo ""

    # Create a basic Prisma schema with a User model
    cat > prisma/schema.prisma << PRISMA_EOF
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
PRISMA_EOF
    echo "Example Prisma schema with a 'User' model has been added."
    echo ""

    # Create a Docker Compose file for PostgreSQL
    cat > docker-compose.yml << DOCKER_EOF
services:
  db:
    image: postgres
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: postgres
    ports:
      - '5555:5432'
    volumes:
      - db-data:/var/lib/postgresql/data
volumes:
  db-data:
DOCKER_EOF
    echo "Database and Prisma setup complete!"
    echo ""
fi

# Instructions for the user to run the servers
echo ""
echo "Setup is complete!"
echo ""
echo "To run the frontend development server:"
echo "1. Navigate to the frontend directory:"
echo "   cd $dirName/frontend"
echo "2. Start the development server:"
echo "   bun dev"
echo ""

echo "To run the backend server:"
echo "1. Navigate to the backend directory:"
echo "   cd $dirName/backend"
echo "2. Start the server:"
echo "   bun run index.ts"
echo ""

if [[ "$needDatabase" =~ ^[Yy]$ ]]; then
    echo "To start the PostgreSQL database with Docker:"
    echo "1. Make sure the Docker app is running."
    echo "2. Navigate to the backend directory:"
    echo "   cd $dirName/backend"
    echo "3. Start the Docker container:"
    echo "   docker-compose up -d"
    echo "4. Apply Prisma migrations to create the User table:"
    echo "   npx prisma migrate dev --name init"
    echo "5. Use Prisma Studio to inspect the database:"
    echo "   npx prisma studio"
    echo ""
fi

echo "Happy coding!"
