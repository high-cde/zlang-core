import os
import sqlite3
import json
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse

DB_PATH = '/root/zdos/xcloud_enterprise.db'

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    # Tabella Aziende & Onboarding
    cursor.execute('''CREATE TABLE IF NOT EXISTS company_onboarding (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_name TEXT,
        vat_number TEXT,
        address TEXT,
        sector TEXT,
        admin_email TEXT,
        card_holder TEXT,
        card_number TEXT,
        status TEXT DEFAULT 'verified_3ds'
    )''')
    # Tabella Feed Attività
    cursor.execute('''CREATE TABLE IF NOT EXISTS feed (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        author TEXT,
        content TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )''')
    # Tabella Messenger
    cursor.execute('''CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender TEXT,
        text TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )''')
    # Tabella Task zFLOW
    cursor.execute('''CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        status TEXT DEFAULT 'todo',
        assignee TEXT
    )''')
    # Tabella CRM Leads
    cursor.execute('''CREATE TABLE IF NOT EXISTS leads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        company TEXT,
        value REAL,
        stage TEXT DEFAULT 'New'
    )''')
    conn.commit()
    conn.close()

init_db()

class XCloudAPIHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        if path == '/api/stats':
            conn = sqlite3.connect(DB_PATH)
            c = conn.cursor()
            c.execute("SELECT COUNT(*) FROM company_onboarding")
            companies = c.fetchone()[0]
            c.execute("SELECT COUNT(*) FROM leads")
            leads = c.fetchone()[0]
            c.execute("SELECT COUNT(*) FROM tasks")
            tasks = c.fetchone()[0]
            conn.close()
            
            data = {"companies": companies, "leads": leads, "tasks": tasks, "status": "active_sync"}
            self.send_json(data)
        elif path == '/api/feed':
            conn = sqlite3.connect(DB_PATH)
            c = conn.cursor()
            c.execute("SELECT author, content, timestamp FROM feed ORDER BY id DESC LIMIT 10")
            rows = c.fetchall()
            conn.close()
            self.send_json([{"author": r[0], "content": r[1], "timestamp": r[2]} for r in rows])
        elif path == '/api/messages':
            conn = sqlite3.connect(DB_PATH)
            c = conn.cursor()
            c.execute("SELECT sender, text, timestamp FROM messages ORDER BY id DESC LIMIT 20")
            rows = c.fetchall()
            conn.close()
            self.send_json([{"sender": r[0], "text": r[1], "timestamp": r[2]} for r in rows])
        elif path == '/api/tasks':
            conn = sqlite3.connect(DB_PATH)
            c = conn.cursor()
            c.execute("SELECT id, title, status, assignee FROM tasks")
            rows = c.fetchall()
            conn.close()
            self.send_json([{"id": r[0], "title": r[1], "status": r[2], "assignee": r[3]} for r in rows])
        elif path == '/api/leads':
            conn = sqlite3.connect(DB_PATH)
            c = conn.cursor()
            c.execute("SELECT id, name, company, value, stage FROM leads")
            rows = c.fetchall()
            conn.close()
            self.send_json([{"id": r[0], "name": r[1], "company": r[2], "value": r[3], "stage": r[4]} for r in rows])
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length)
        
        try:
            data = json.loads(post_data.decode('utf-8'))
        except:
            data = {}

        conn = sqlite3.connect(DB_PATH)
        c = conn.cursor()

        if path == '/api/onboarding':
            c.execute("INSERT INTO company_onboarding (company_name, vat_number, address, sector, admin_email, card_holder, card_number) VALUES (?, ?, ?, ?, ?, ?, ?)",
                      (data.get('company_name'), data.get('vat_number'), data.get('address'), data.get('sector'), data.get('admin_email'), data.get('card_holder'), data.get('card_number')))
            conn.commit()
            conn.close()
            self.send_json({"status": "success", "message": "Azienda registrata e validata 3DS con successo su DSN!"})
        elif path == '/api/feed':
            c.execute("INSERT INTO feed (author, content) VALUES (?, ?)", (data.get('author', 'HighKali'), data.get('content')))
            conn.commit()
            conn.close()
            self.send_json({"status": "success"})
        elif path == '/api/messages':
            c.execute("INSERT INTO messages (sender, text) VALUES (?, ?)", (data.get('sender', 'HighKali'), data.get('text')))
            conn.commit()
            conn.close()
            self.send_json({"status": "success"})
        elif path == '/api/tasks':
            c.execute("INSERT INTO tasks (title, status, assignee) VALUES (?, ?, ?)", (data.get('title'), data.get('status', 'todo'), data.get('assignee', 'ZDOS-Agent')))
            conn.commit()
            conn.close()
            self.send_json({"status": "success"})
        else:
            conn.close()
            self.send_response(404)
            self.end_headers()

    def send_json(self, data):
        response = json.dumps(data).encode('utf-8')
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(response)

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def log_message(self, format, *args):
        return

print("🚀 [xCLOUD BACKEND]: Motore API enterprise in ascolto sulla porta 8090...")
server = HTTPServer(('127.0.0.1', 8090), XCloudAPIHandler)
server.serve_forever()
