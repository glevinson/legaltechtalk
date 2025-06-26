#!/bin/bash

# Legal Conversation System - Docker Setup Script

echo "🏛️  Legal Conversation System - Docker Setup"
echo "============================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first:"
    echo "   https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install Docker Compose:"
    echo "   https://docs.docker.com/compose/install/"
    exit 1
fi

# Check for OpenAI API key
if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  OPENAI_API_KEY environment variable is not set."
    echo "Please set your OpenAI API key:"
    echo "   export OPENAI_API_KEY='your-api-key-here'"
    echo ""
    echo "Or create a .env file with:"
    echo "   OPENAI_API_KEY=your-api-key-here"
    echo ""
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "🔨 Building Docker containers..."
docker-compose build

if [ $? -ne 0 ]; then
    echo "❌ Docker build failed"
    exit 1
fi

echo ""
echo "🚀 Starting services..."
docker-compose up -d

if [ $? -ne 0 ]; then
    echo "❌ Failed to start services"
    exit 1
fi

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if API is healthy
echo "🏥 Checking API health..."
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ API is healthy!"
else
    echo "⚠️  API health check failed. Checking logs..."
    docker-compose logs legal-conversation-api
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Available services:"
echo "  📡 API Server:        http://localhost:8000"
echo "  📚 API Documentation: http://localhost:8000/docs"
echo "  🌐 Web Interface:     http://localhost:3000"
echo ""
echo "Useful commands:"
echo "  📋 View logs:         docker-compose logs -f"
echo "  🛑 Stop services:     docker-compose down"
echo "  🔄 Restart:           docker-compose restart"
echo "  🗑️  Remove containers: docker-compose down -v"
echo ""
echo "Happy chatting with Iris! 🤖"