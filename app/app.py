import os

import requests
from flask import Flask, request, jsonify

app = Flask(__name__)

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://host.docker.internal:11434/api/generate")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3.2")
OLLAMA_TIMEOUT = int(os.getenv("OLLAMA_TIMEOUT", "60"))


@app.route("/")
def home():
    return "AI Chatbot is running! Use /chat endpoint"


@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200


@app.route("/chat", methods=["POST"])
def chat():
    data = request.get_json(silent=True) or {}
    user_message = data.get("message", "").strip()

    if not user_message:
        return jsonify({"error": "message is required"}), 400

    try:
        resp = requests.post(
            OLLAMA_URL,
            json={"model": OLLAMA_MODEL, "prompt": user_message, "stream": False},
            timeout=OLLAMA_TIMEOUT,
        )
        resp.raise_for_status()
        return jsonify({"response": resp.json()["response"]})
    except requests.Timeout:
        return jsonify({"error": "model took too long to respond"}), 504
    except (requests.RequestException, KeyError, ValueError):
        return jsonify({"error": "could not get a response from the model"}), 502


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
