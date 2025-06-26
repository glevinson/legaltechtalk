#!/bin/bash

# Quick test script for Docker setup

echo "🧪 Testing Docker Setup"
echo "======================="

# Test build
echo "1. Testing Docker build..."
if docker-compose build --quiet; then
    echo "✅ Docker build successful"
else
    echo "❌ Docker build failed"
    exit 1
fi

# Test if we can start without API key (should show error)
echo ""
echo "2. Testing startup without API key..."
unset OPENAI_API_KEY
docker-compose up -d legal-conversation-api

sleep 5

# Check logs for API key error
if docker-compose logs legal-conversation-api 2>&1 | grep -q "OPENAI_API_KEY"; then
    echo "✅ Correctly detects missing API key"
else
    echo "⚠️  API key validation may not be working"
fi

# Clean up
docker-compose down

echo ""
echo "3. Testing with mock API key..."
export OPENAI_API_KEY="test-key-123"
docker-compose up -d legal-conversation-api

sleep 10

# Test health endpoint
echo ""
echo "4. Testing health endpoint..."
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ Health endpoint responding"
else
    echo "❌ Health endpoint not responding"
    echo "Logs:"
    docker-compose logs --tail=10 legal-conversation-api
fi

# Clean up
echo ""
echo "🧹 Cleaning up..."
docker-compose down

echo ""
echo "✅ Docker test complete!"
echo "Your colleague can now run: ./docker-setup.sh"