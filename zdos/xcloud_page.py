import os

html_content = '''<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>xCLOUD Enterprise // ZDOS Real Enterprise Suite</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --sidebar-bg: #0f1c2e;
            --header-bg: #1b2838;
            --main-bg: #f4f6f8;
            --card-bg: #ffffff;
            --primary-blue: #2067b0;
            --text-dark: #121a24;
            --text-muted: #64748b;
            --accent-green: #0ecb81;
            --accent-cyan: #00b4d8;
            --border-color: #e2e8f0;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Inter', sans-serif; }
        body { background: var(--main-bg); color: var(--text-dark); display: flex; height: 100vh; overflow: hidden; }
        
        /* Sidebar */
        .sidebar { width: 280px; background: var(--sidebar-bg); color: #fff; display: flex; flex-direction: column; height: 100%; border-right: 1px solid rgba(255,255,255,0.08); overflow-y: auto; }
        .sidebar-brand { padding: 18px 20px; font-weight: 700; font-size: 1rem; background: var(--header-bg); border-bottom: 1px solid rgba(255,255,255,0.1); display: flex; align-items: center; gap: 10px; }
        .sidebar-menu { padding: 10px 0; }
        .menu-category { font-size: 0.68rem; text-transform: uppercase; color: #94a3b8; padding: 10px 20px 4px 20px; font-weight: 700; letter-spacing: 0.5px; }
        .menu-item { padding: 10px 20px; color: #cbd5e1; font-size: 0.82rem; cursor: pointer; display: flex; align-items: center; gap: 10px; text-decoration: none; transition: 0.2s; }
        .menu-item:hover, .menu-item.active { background: rgba(32, 103, 176, 0.3); color: #fff; border-left: 4px solid var(--accent-cyan); }

        /* Main Content */
        .main-container { flex: 1; display: flex; flex-direction: column; height: 100%; overflow: hidden; }
        .top-header { height: 60px; background: #fff; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center; padding: 0 24px; }
        .search-box { background: var(--main-bg); border: 1px solid var(--border-color); border-radius: 20px; padding: 6px 16px; width: 320px; font-size: 0.82rem; color: var(--text-dark); }
        .content-body { flex: 1; padding: 24px; overflow-y: auto; display: none; }
        .content-body.active { display: block; }

        /* Cards & Form */
        .card { background: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; padding: 24px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); margin-bottom: 20px; max-width: 800px; }
        .card-title { font-size: 1.1rem; font-weight: 700; margin-bottom: 16px; color: var(--text-dark); display: flex; align-items: center; gap: 8px; }
        .form-group { margin-bottom: 14px; }
        .form-label { display: block; font-size: 0.78rem; font-weight: 600; color: var(--text-muted); margin-bottom: 6px; }
        .form-control { width: 100%; padding: 10px 14px; border: 1px solid var(--border-color); border-radius: 8px; font-size: 0.85rem; outline: none; }
        .form-control:focus { border-color: var(--primary-blue); box-shadow: 0 0 0 3px rgba(32,103,176,0.15); }
        .btn { background: var(--primary-blue); color: #fff; border: none; padding: 12px 20px; border-radius: 8px; font-weight: 600; font-size: 0.88rem; cursor: pointer; width: 100%; transition: 0.2s; }
        .btn:hover { background: #18528f; }

        .badge-live { background: rgba(14,203,129,0.15); color: var(--accent-green); padding: 4px 10px; border-radius: 12px; font-size: 0.72rem; font-weight: 700; display: inline-block; }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-brand">
            <span>🛡️ xCLOUD Enterprise</span>
        </div>
        <div class="sidebar-menu">
            <div class="menu-category">Onboarding & Registrazione</div>
            <a class="menu-item active" onclick="switchSection('onboarding', this)">📝 Registrazione Account Completa</a>
            
            <div class="menu-category">Collaborazione</div>
            <a class="menu-item" onclick="switchSection('feed', this)">📢 Feed (Flusso Attività)</a>
            <a class="menu-item" onclick="switchSection('messenger', this)">💬 Messenger & Chiamate</a>
            <a class="menu-item" onclick="switchSection('calendar', this)">📅 Calendario</a>
            <a class="menu-item" onclick="switchSection('drive', this)">📁 Drive Cloud</a>
            <a class="menu-item" onclick="switchSection('webmail', this)">✉️ Webmail Aziendale</a>
            
            <div class="menu-category">CRM & Vendite</div>
            <a class="menu-item" onclick="switchSection('crm', this)">📊 CRM (Panoramica Lead)</a>
            <a class="menu-item" onclick="switchSection('zflow', this)">📋 Incarichi & Progetti (zFLOW)</a>
            
            <div class="menu-category">Sistema ZDOS</div>
            <a href="/wallet.html" class="menu-item">💎 Web3 DSN Wallet</a>
            <a href="/lab.html" class="menu-item">⚡ ZDOS Silicon Lab</a>
            <a class="menu-item" onclick="switchSection('admin', this)">⚙️ Impostazioni Admin</a>
        </div>
    </div>

    <div class="main-container">
        <div class="top-header">
            <input type="text" class="search-box" placeholder="Cerca task, lead, documenti su xCLOUD...">
            <div style="display:flex; align-items:center; gap:14px;">
                <span class="badge-live">● ZDOS Backend Live</span>
                <div style="background:var(--primary-blue); color:#fff; width:34px; height:34px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:0.85rem;">HK</div>
            </div>
        </div>

        <!-- SEZIONE 1: ONBOARDING -->
        <div id="sec-onboarding" class="content-body active">
            <div class="card">
                <div class="card-title">📝 Registrazione Account xCLOUD Enterprise</div>
                <p style="font-size:0.82rem; color:var(--text-muted); margin-bottom:20px;">Configura la tua azienda e attiva l'ambiente di lavoro certificato su DSN con validazione 3DS.</p>
                <form id="onboardingForm" onsubmit="submitOnboarding(event)">
                    <div class="form-group">
                        <label class="form-label">Ragione Sociale Azienda</label>
                        <input type="text" class="form-control" id="compName" placeholder="es. ZDOS Enterprise Srl" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Partita IVA / Codice Fiscale</label>
                        <input type="text" class="form-control" id="vat" placeholder="IT01234567890" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Indirizzo Sede Legale & Città</label>
                        <input type="text" class="form-control" id="address" placeholder="Garivalda, Pietra De' Giorgi (PV)" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Email Amministratore / Referente</label>
                        <input type="email" class="form-control" id="email" placeholder="admin@x-zdos.it" required>
                    </div>
                    <div class="card" style="background:#f8fafc; border:1px solid #cbd5e1; margin-top:16px; padding:16px;">
                        <div style="font-weight:700; font-size:0.85rem; margin-bottom:10px;">💳 Validazione Carta & Metodo di Pagamento (3DS)</div>
                        <div class="form-group">
                            <input type="text" class="form-control" id="cardHolder" placeholder="Titolare Carta" required>
                        </div>
                        <div class="form-group">
                            <input type="text" class="form-control" id="cardNumber" placeholder="Numero Carta (xxxx xxxx xxxx xxxx)" required>
                        </div>
                    </div>
                    <button type="submit" class="btn">Completa Registrazione Azienda & Firma zLB2</button>
                </form>
            </div>
        </div>

        <!-- SEZIONE 2: FEED -->
        <div id="sec-feed" class="content-body">
            <div class="card">
                <div class="card-title">📢 Feed & Flusso Attività (Real-time)</div>
                <div id="feedList" style="font-size:0.85rem; color:var(--text-muted);">Caricamento feed da SQLite...</div>
            </div>
        </div>

        <!-- SEZIONE 3: MESSENGER -->
        <div id="sec-messenger" class="content-body">
            <div class="card">
                <div class="card-title">💬 Messenger Aziendale zComm</div>
                <div id="msgList" style="font-size:0.85rem; color:var(--text-muted); margin-bottom:14px; max-height:200px; overflow-y:auto;">Nessun messaggio recente.</div>
                <div style="display:flex; gap:10px;">
                    <input type="text" class="form-control" id="msgInput" placeholder="Scrivi un messaggio...">
                    <button class="btn" style="width:120px;" onclick="sendMessage()">Invia</button>
                </div>
            </div>
        </div>

        <!-- SEZIONE 4: CALENDARIO -->
        <div id="sec-calendar" class="content-body">
            <div class="card">
                <div class="card-title">📅 Calendario Sinaptico & Riunioni</div>
                <p style="font-size:0.85rem; color:var(--text-muted);">Tutti gli eventi di sincronizzazione con il kernel ZDOS sono attivi. Prossimo meeting con i nodi DSN programmato alle ore 18:00.</p>
            </div>
        </div>

        <!-- SEZIONE 5: DRIVE -->
        <div id="sec-drive" class="content-body">
            <div class="card">
                <div class="card-title">📁 Drive Cloud & Storage Immutabile</div>
                <p style="font-size:0.85rem; color:var(--text-muted);">Spazio di archiviazione protetto da crittografia zKR. File di configurazione e backup sincronizzati con `/var/www/x-zdos`.</p>
            </div>
        </div>

        <!-- SEZIONE 6: WEBMAIL -->
        <div id="sec-webmail" class="content-body">
            <div class="card">
                <div class="card-title">✉️ Webmail Aziendale Sicura</div>
                <p style="font-size:0.85rem; color:var(--text-muted);">Casella di posta cifrata attiva per <code>admin@x-zdos.it</code>.</p>
            </div>
        </div>

        <!-- SEZIONE 7: CRM -->
        <div id="sec-crm" class="content-body">
            <div class="card">
                <div class="card-title">📊 CRM & Panoramica Lead</div>
                <div id="leadList" style="font-size:0.85rem; color:var(--text-muted);">Nessun lead censito nel database corrente.</div>
            </div>
        </div>

        <!-- SEZIONE 8: ZFLOW -->
        <div id="sec-zflow" class="content-body">
            <div class="card">
                <div class="card-title">📋 zFLOW Task Engine</div>
                <div id="taskList" style="font-size:0.85rem; color:var(--text-muted); margin-bottom:14px;">Caricamento task...</div>
                <div style="display:flex; gap:10px;">
                    <input type="text" class="form-control" id="taskInput" placeholder="Nuovo incarico / task...">
                    <button class="btn" style="width:140px;" onclick="createTask()">Aggiungi Task</button>
                </div>
            </div>
        </div>

        <!-- SEZIONE 9: ADMIN -->
        <div id="sec-admin" class="content-body">
            <div class="card">
                <div class="card-title">⚙️ Impostazioni Admin & Stato VPS</div>
                <p style="font-size:0.85rem; color:var(--text-muted);">VPS Contabo vmi3082470 operativa. Servizi backend attivi e sincronizzati.</p>
            </div>
        </div>
    </div>

    <script>
        function switchSection(secId, element) {
            document.querySelectorAll('.content-body').forEach(el => el.classList.remove('active'));
            document.getElementById('sec-' + secId).classList.add('active');
            document.querySelectorAll('.menu-item').forEach(el => el.classList.remove('active'));
            if(element) element.classList.add('active');
            
            if(secId === 'feed') loadFeed();
            if(secId === 'messenger') loadMessages();
            if(secId === 'zflow') loadTasks();
            if(secId === 'crm') loadLeads();
        }

        async function submitOnboarding(e) {
            e.preventDefault();
            const data = {
                company_name: document.getElementById('compName').value,
                vat_number: document.getElementById('vat').value,
                address: document.getElementById('address').value,
                admin_email: document.getElementById('email').value,
                card_holder: document.getElementById('cardHolder').value,
                card_number: document.getElementById('cardNumber').value
            };
            const res = await fetch('/api/onboarding', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(data)
            });
            const json = await res.json();
            alert(json.message || 'Registrazione completata!');
        }

        async function loadFeed() {
            const res = await fetch('/api/feed');
            const data = await res.json();
            const container = document.getElementById('feedList');
            if(data.length === 0) { container.innerHTML = 'Nessuna attività recente.'; return; }
            container.innerHTML = data.map(i => `<div style="padding:8px 0; border-bottom:1px solid #e2e8f0;"><strong>${i.author}</strong>: ${i.content} <span style="font-size:0.7rem; color:#94a3b8; float:right;">${i.timestamp}</span></div>`).join('');
        }

        async function loadMessages() {
            const res = await fetch('/api/messages');
            const data = await res.json();
            const container = document.getElementById('msgList');
            if(data.length === 0) { container.innerHTML = 'Nessun messaggio.'; return; }
            container.innerHTML = data.map(i => `<div><strong>${i.sender}</strong>: ${i.text}</div>`).join('');
        }

        async function sendMessage() {
            const text = document.getElementById('msgInput').value;
            if(!text) return;
            await fetch('/api/messages', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({sender: 'HighKali', text: text})
            });
            document.getElementById('msgInput').value = '';
            loadMessages();
        }

        async function loadTasks() {
            const res = await fetch('/api/tasks');
            const data = await res.json();
            const container = document.getElementById('taskList');
            if(data.length === 0) { container.innerHTML = 'Nessun task attivo.'; return; }
            container.innerHTML = data.map(i => `<div style="padding:6px 0; border-bottom:1px solid #e2e8f0;">📌 ${i.title} <span style="float:right; color:var(--primary-blue);">[${i.status}]</span></div>`).join('');
        }

        async function createTask() {
            const title = document.getElementById('taskInput').value;
            if(!title) return;
            await fetch('/api/tasks', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({title: title, status: 'todo'})
            });
            document.getElementById('taskInput').value = '';
            loadTasks();
        }

        async function loadLeads() {
            const res = await fetch('/api/leads');
            const data = await res.json();
            const container = document.getElementById('leadList');
            if(data.length === 0) { container.innerHTML = 'Nessun lead nel CRM.'; return; }
            container.innerHTML = data.map(i => `<div>🏢 ${i.company} — Contatto: ${i.name} (€ ${i.value})</div>`).join('');
        }
    </script>
</body>
</html>
'''

with open('/var/www/html/xcloud.html', 'w') as f:
    f.write(html_content)

print("✨ [SUCCESS]: Pagina xcloud.html generata e collegata al backend SQLite in tempo reale!")
