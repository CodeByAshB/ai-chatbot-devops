from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

OLLAMA_URL = "http://host.docker.internal:11434/api/generate"

@app.route('/')
def home():
    return "AI Chatbot is running! Use /chat endpoint"

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    user_message = data.get('message', '')

    response = requests.post(OLLAMA_URL, json={
        "model": "llama3.2",
        "prompt": user_message,
        "stream": False
    })

    result = response.json()
    return jsonify({
        "response": result['response']
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
