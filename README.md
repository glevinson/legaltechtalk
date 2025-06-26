# Legal Multi-Agent Conversation System

This system implements a multi-agent workflow for legal client onboarding, featuring Iris (AI front-of-house) who gathers information and passes it to a drafting agent for pitch deck creation. Built using LangGraph for the [LegalTechTalk Hackathon](https://www.legaltech-talk.com/legaltechtalk-hackathon/).

## 🏗️ Architecture

The system consists of:
- **Iris (Conversation Agent)**: AI front-of-house that classifies legal needs and gathers information
- **Drafting Agent**: Receives conversation data and prepares pitch decks (currently TODO implementation)
- **API Backend**: FastAPI server for frontend integration without CLI prompts

## 🚀 Quick Start

### Option 1: Docker (Recommended - Easiest Setup)

**✅ Tested and Working!**

**One-command setup:**
```bash
# Set your OpenAI API key
export OPENAI_API_KEY="your-api-key-here"

# Run the setup script
./docker-setup.sh
```

**Manual Docker setup:**
```bash
# Set your API key
export OPENAI_API_KEY="your-api-key-here"

# Build and start the API service
docker-compose up -d legal-conversation-api

# Check if running (should return: {"status":"healthy"})
curl http://localhost:8000/health

# Test conversation start
curl -X POST http://localhost:8000/conversation/start -H "Content-Type: application/json" -d "{}"
```

**Access the system:**
- 📡 **API Server**: http://localhost:8000
- 📚 **API Docs**: http://localhost:8000/docs (Interactive API testing)
- 🏥 **Health Check**: http://localhost:8000/health

**Stop the system:**
```bash
docker-compose down
```

### Option 2: Local Development

**Prerequisites:**
1. Python 3.12+ and Poetry installed
2. Set your OpenAI API key:
```bash
export OPENAI_API_KEY="your-api-key-here"
```

**Install and run:**
```bash
# Install dependencies
poetry install
poetry add fastapi "uvicorn[standard]"

# Start API server
poetry run uvicorn src.hackathon.agents.conversation.api:app --reload --port 8000

# OR run interactive CLI demo
poetry run python src/hackathon/agents/conversation/interactive_demo.py
```

## 📡 API Integration Guide

### Important: No CLI Prompts!
The API handles conversations without any CLI interaction. Each request returns Iris's response for direct frontend display.

### 1. Start Conversation
```javascript
// Start new conversation
const response = await fetch('http://localhost:8000/conversation/start', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({})
});
const data = await response.json();
// Display data.message in your chat UI
// Store data.thread_id for subsequent messages
```

Response contains Iris's introduction:
```json
{
  "thread_id": "conv_123",
  "message": "Hello! I'm Iris, the AI front-of-house...",
  "status": "active"
}
```

### 2. Send Messages
```javascript
// Send user message
const response = await fetch('http://localhost:8000/conversation/message', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    thread_id: threadId,
    message: userInput
  })
});
const data = await response.json();
// Display data.message in chat UI
```

### 3. Monitor Conversation State
- `conversation_complete`: Whether Iris has gathered enough information
- `conversation_ended`: **True only when `end_conversation` tool was called in this response**
- `legal_area`: The classified legal area (e.g., "mergers_and_acquisitions")
- `draft_ready`: Whether the pitch deck has been generated

**Key Difference:**
- `conversation_ended: true` = Iris just called `end_conversation` in this specific response
- `conversation_complete: true` = The overall conversation workflow is finished

## 🛠️ How It Works

1. **Iris Introduction**: Iris introduces herself as the AI front-of-house
2. **Legal Area Classification**: Based on input, Iris uses the `classify_legal_area` tool
3. **Targeted Questions**: Iris asks specific questions based on the legal area
4. **Information Gathering**: Continues until sufficient information is collected
5. **Handoff**: Calls `end_conversation` and passes data to drafting agent

## 📂 Project Structure

- **`src/hackathon/agents/conversation/`**: Main conversation system
  - `api.py`: FastAPI backend
  - `conversation_agent.py`: Iris implementation
  - `graph.py`: Multi-agent workflow orchestration
  - `api_graph.py`: API-specific graph without CLI prompts
  - `drafting_node.py`: Drafting agent (TODO)

## 🐛 Docker Troubleshooting

### Common Issues

**1. Port already in use:**
```bash
# Check what's using the port
lsof -i :8000
# Kill the process or use different ports in docker-compose.yml
```

**2. API key not working:**
```bash
# Verify your API key is set
echo $OPENAI_API_KEY
# Or check Docker logs
docker-compose logs legal-conversation-api
```

**3. Container won't start:**
```bash
# Check logs
docker-compose logs -f
# Rebuild containers
docker-compose down && docker-compose build --no-cache && docker-compose up
```

**4. Permission issues (Linux/Mac):**
```bash
# Make setup script executable
chmod +x docker-setup.sh
```

### Useful Commands

```bash
# View all logs
docker-compose logs -f

# Restart just the API
docker-compose restart legal-conversation-api

# Stop everything
docker-compose down

# Remove everything (including volumes)
docker-compose down -v

# Rebuild from scratch
docker-compose build --no-cache
```

## 📚 Full Documentation

For detailed API documentation, frontend examples, and development guide, see:
[**src/hackathon/agents/conversation/README.md**](src/hackathon/agents/conversation/README.md)

## 3. Additional Resources (Optional)

### Run LLMs Locally with Ollama

[Ollama](https://ollama.com/) is an open-source tool that allows you to run large language models locally on your machine. Follow these steps to set up Ollama:
1. Download and install the Ollama desktop app from https://ollama.com/download
2. Run the command `ollama` in your terminal to verify the installation was successful
3. Select a model from the [Ollama library](https://ollama.com/library). Keep in mind that:
    - The model should support tool/function calling to enable agentic use cases
    - As a general rule, you should have at least 8 GB of RAM available to run 8B models, 16 GB to run 16B models, and so on
    - We recommend using the [Qwen3 family of models](https://ollama.com/library/qwen3): `qwen3:8b` if you have 8 GB of RAM, `qwen3:14b` if you have 16 GB, or `qwen3:32b` if you have 32 GB
4. Run the command `ollama run <your_model>` in your terminal to download the model. When the download is complete, a chat interface will start with the selected model. Type `/bye` to exit the chat interface
5. In the `.env` file, set `MODEL_PROVIDER` to `"ollama"` and `OLLAMA_MODEL` to your model of choice
6. Finally, start the Ollama app in the background OR run `ollama serve` in your terminal to expose an HTTP API on localhost so you can send requests to the model via Python code

### Explore Further

See the following resources to learn more about:
- AI agents: https://www.anthropic.com/engineering/building-effective-agents
- LangGraph (free) course: https://academy.langchain.com/courses/intro-to-langgraph
- LangGraph advanced examples: https://langchain-ai.github.io/langgraph/tutorials/overview
