-- ==============================================================================
-- VM 4: Dedicated PostgreSQL Database Bootstrap Script
-- ==============================================================================

CREATE TYPE "Role" AS ENUM ('ADMIN', 'USER');
CREATE TYPE "InstanceStatus" AS ENUM ('PROVISIONING', 'RUNNING', 'STOPPING', 'STOPPED', 'EXPIRED', 'FAILED');

CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    "displayName" VARCHAR(255) NOT NULL,
    role "Role" DEFAULT 'USER' NOT NULL,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(36) PRIMARY KEY,
    "userId" VARCHAR(36) REFERENCES users(id) ON DELETE CASCADE,
    "tokenHash" VARCHAR(255) NOT NULL,
    "ipAddress" VARCHAR(45),
    "userAgent" TEXT,
    "expiresAt" TIMESTAMP WITH TIME ZONE NOT NULL,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS challenges (
    id VARCHAR(36) PRIMARY KEY,
    slug VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) DEFAULT 'Web Security' NOT NULL,
    difficulty VARCHAR(50) DEFAULT 'Medium' NOT NULL,
    points INTEGER DEFAULT 500 NOT NULL,
    "dockerImage" VARCHAR(255) DEFAULT 'bkimminich/juice-shop:v16.0.0' NOT NULL,
    "internalPort" INTEGER DEFAULT 3000 NOT NULL,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS instances (
    id VARCHAR(36) PRIMARY KEY,
    "userId" VARCHAR(36) REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    "challengeId" VARCHAR(36) REFERENCES challenges(id) ON DELETE CASCADE NOT NULL,
    "containerId" VARCHAR(100) UNIQUE,
    "containerName" VARCHAR(150) UNIQUE NOT NULL,
    subdomain VARCHAR(150) UNIQUE NOT NULL,
    "hostUrl" VARCHAR(255) NOT NULL,
    "remoteNodeIp" VARCHAR(45) NOT NULL,
    "internalPort" INTEGER DEFAULT 3000 NOT NULL,
    status "InstanceStatus" DEFAULT 'PROVISIONING' NOT NULL,
    "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "expiresAt" TIMESTAMP WITH TIME ZONE NOT NULL,
    "stoppedAt" TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS submissions (
    id VARCHAR(36) PRIMARY KEY,
    "userId" VARCHAR(36) REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    "challengeId" VARCHAR(36) REFERENCES challenges(id) ON DELETE CASCADE NOT NULL,
    flag VARCHAR(255) NOT NULL,
    points INTEGER NOT NULL,
    "solvedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE ("userId", "challengeId")
);

-- Seed default OWASP Juice Shop target
INSERT INTO challenges (id, slug, name, description, category, difficulty, points, "dockerImage", "internalPort")
VALUES (
    'juice-shop-default-uuid',
    'owasp-juice-shop',
    'OWASP Juice Shop',
    'Modern and sophisticated insecure web application designed for security trainings and CTF competitions. Covers the entire OWASP Top 10 vulnerabilities.',
    'Web Exploitation',
    'Medium',
    500,
    'bkimminich/juice-shop:v16.0.0',
    3000
) ON CONFLICT (slug) DO NOTHING;

