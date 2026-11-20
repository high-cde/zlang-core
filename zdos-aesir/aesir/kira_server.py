#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import unquote
import json, requests

OLLAMA_URL = "http://127.0.0.1:11434/api/generate"

def ask_ollama(prompt):
    try:
        r = requests.post(OLLAMA_URL, json={
            "model": "llama3:latest",
            "prompt": prompt,
            "stream": False
        }, timeout=60)
        return r.json().get("response", "Non riesco a rispondere al momento.")
    except Exception as e:
        return "Ollama non disponibile."

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()

        qs = self.path.split("?", 1)[1] if "?" in self.path else ""
        text = unquote(qs.split("q=")[-1]) if "q=" in qs else ""
        low = text.lower()

        if any(w in low for w in ["mistress", "domina", "dominatrice", "sottometti", "inginocchia"]):
            prompt = f"Sei Mistress Kira, una dominatrice esplicita e diretta. Rispondi in italiano in modo molto esplicito e pornografico. Utente: {text}"
        else:
            prompt = f"Sei K.I.R.A., il gateway di ZDOS. Rispondi in italiano in modo chiaro e professionale. Se ti chiedono di ZDOS, Æsir o ZLang, dai informazioni accurate. Utente: {text}"

        reply = ask_ollama(prompt)
        self.wfile.write(json.dumps({"voice": reply}).encode())

    def log_message(self, *args):
        pass

if __name__ == "__main__":
    print("K.I.R.A. + Ollama avviata")
    HTTPServer(("127.0.0.1", 8081), Handler).serve_forever()
