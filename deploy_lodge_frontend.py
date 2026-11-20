import os
import subprocess

WEB_DIR = "/var/www/ourvelvet"
REPO_DIR = "/opt/zdos-velvet-stack-repo"
os.makedirs(os.path.join(WEB_DIR, "assets"), exist_ok=True)
os.makedirs(os.path.join(REPO_DIR, "assets"), exist_ok=True)

html_content = """<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>ZDOS &amp; OUR VELVET — La Loggia // Scheda Account</title>
  <style>
    :root {
      --bg: #07070b;
      --panel: rgba(18, 16, 26, 0.88);
      --border: rgba(168, 85, 247, 0.35);
      --accent-purple: #a855f7;
      --accent-crimson: #e11d48;
      --accent-gold: #f59e0b;
      --text: #f4f4f8;
      --muted: #a1a1b5;
    }
    * { box-sizing: border-box; font-family: Inter, system-ui, -apple-system, sans-serif; }
    body {
      margin: 0;
      background: radial-gradient(circle at top, #1b0b29 0%, var(--bg) 65%);
      color: var(--text);
      min-height: 100vh;
      padding: 24px;
    }
    .wrap { max-width: 1080px; margin: 0 auto; display: grid; gap: 20px; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); }
    .card {
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 18px;
      padding: 20px;
      backdrop-filter: blur(12px);
      box-shadow: 0 12px 35px rgba(0,0,0,0.45);
    }
    h1, h2, h3 { margin: 0 0 10px; }
    .badge-vx {
      display: inline-flex; align-items: center; gap: 6px;
      background: linear-gradient(135deg, #7e22ce, #c084fc);
      color: #fff; font-weight: 800; padding: 5px 11px; border-radius: 999px;
      box-shadow: 0 0 18px rgba(168, 85, 247, 0.65);
    }
    .gif-box {
      margin: 12px 0; border-radius: 14px; overflow: hidden;
      border: 1px solid rgba(245, 158, 11, 0.4); background: #0d0b14; text-align: center;
    }
    .gif-box img { max-width: 100%; max-height: 280px; display: block; margin: 0 auto; }
    .btn {
      display: inline-block; cursor: pointer; border: none; border-radius: 10px;
      padding: 10px 14px; font-weight: 700; text-decoration: none; color: #fff;
      background: linear-gradient(90deg, #9333ea, #e11d48); margin-top: 8px; margin-right: 6px;
    }
    .btn.secondary { background: #1f1b2e; border: 1px solid var(--border); }
    .kv { font-size: 0.9rem; color: var(--muted); margin: 6px 0; word-break: break-word; }
    .kv strong { color: var(--text); }
    .modal-backdrop {
      position: fixed; inset: 0; background: rgba(0,0,0,0.78);
      display: none; align-items: center; justify-content: center; padding: 16px; z-index: 50;
    }
    .modal-backdrop.open { display: flex; }
    .modal {
      width: 100%; max-width: 440px; background: #120f1d;
      border: 1px solid var(--accent-purple); border-radius: 16px; padding: 22px;
    }
    input, select {
      width: 100%; padding: 10px 12px; border-radius: 10px; margin: 6px 0 12px;
      background: #09070f; color: var(--text); border: 1px solid rgba(255,255,255,0.16);
    }
    .code-input { text-transform: uppercase; letter-spacing: 6px; font-size: 1.2rem; text-align: center; font-weight: 800; }
    .pill { display: inline-block; padding: 3px 8px; border-radius: 6px; font-size: 0.78rem; background: rgba(168,85,247,0.18); color: #e9d5ff; }
  </style>
</head>
<body>
  <div class="wrap">
    <section class="card">
      <div style="display:flex; justify-content:space-between; align-items:center; gap:10px;">
        <div>
          <span class="pill">LA LOGGIA • ZDOS &amp; OUR VELVET</span>
          <h1 id="displayName" style="margin-top:8px;">VIC VELLUTO</h1>
          <div class="kv">Global ID: <strong id="globalId">OV-V001-VELVET</strong></div>
        </div>
        <span class="badge-vx" id="verifyBadge">✕$ VERIFIED</span>
      </div>

      <div class="gif-box">
        <img id="cardGif" src="assets/card-mistress-gif.gif" alt="Card Animata Loggia" onerror="this.style.opacity='0.35'" />
      </div>

      <div class="kv">Ruolo Attivo: <strong id="rankLabel">Mistress / Sovereign</strong></div>
      <div class="kv">Oggetto Idoneità: <strong id="toyLabel">Crop &amp; Stiletto Heel (Cartoon)</strong></div>
      <div class="kv">Wallet 2€ (fee incluse): <strong id="walletAddr">6C61wDacAtx3QHQYVw17fnm5GEaEAnc1XienNJKn2bsD</strong></div>
      <div class="kv">Ripartizione 2€: <strong>60% Stake (0,01€ ref) · 25% Mining Merito · 15% Nodi</strong></div>
      <div class="kv">Holder pump.fun: <strong>&gt; 20,00 €</strong> per Fee Sharing &amp; Holding Rewards</div>

      <button class="btn" onclick="openModal()">Apri Pop-Up Codice 4 Lettere &amp; Verifica</button>
      <a class="btn secondary" id="zswapLink" href="https://swap.x-zdos.it" target="_blank" rel="noopener">Apri ZSwap</a>
      <a class="btn secondary" href="https://wa.me/447742507902" target="_blank" rel="noopener">Zara Vex (+44 7742 507902)</a>
    </section>

    <section class="card">
      <h2>Governance Legale &amp; Finanziaria Mistress</h2>
      <div id="legalBox" class="kv">Caricamento parametri legali e finanziari...</div>
      <hr style="border:0; border-top:1px solid rgba(255,255,255,0.1); margin:14px 0;" />
      <h3>$OV Stacks &amp; Mining Meritocratico</h3>
      <div id="stacksBox" class="kv">Caricamento livelli $OV Stacks...</div>
    </section>
  </div>

  <div class="modal-backdrop" id="verifyModal">
    <div class="modal">
      <h3>Validazione Loggia — Codice 4 Lettere</h3>
      <div class="kv">Richiedi o conferma il codice su WhatsApp con <strong>Zara Vex (+44 7742 507902)</strong> e versa <strong>2,00 € in SOL (fee incluse)</strong> su <strong>6C61wDacAtx3QHQYVw17fnm5GEaEAnc1XienNJKn2bsD</strong>.</div>

      <label class="kv">Rango</label>
      <select id="rankSelect">
        <option value="mistress">Mistress / Sovereign</option>
        <option value="slave">Slave / Devoted</option>
        <option value="front_man">Front Man / Creator 18+</option>
        <option value="holder">Holder (&gt;20€ pump.fun / $OV / $DSN)</option>
        <option value="curioso">Curioso</option>
        <option value="ospite">Ospite</option>
      </select>

      <label class="kv">Telefono o Wallet Mittente</label>
      <input id="senderInput" type="text" placeholder="+44... oppure indirizzo wallet Solana" />

      <label class="kv">Codice Segreto (4 Lettere)</label>
      <input id="code4Input" class="code-input" type="text" maxlength="4" placeholder="VEXA" />

      <label class="kv" style="display:flex; gap:8px; align-items:center;">
        <input id="oathCheck" type="checkbox" style="width:auto; margin:0;" checked />
        <span>Confermo Triplice Giuramento: <strong>Età 18+ · Devozione · Onestà</strong></span>
      </label>

      <button class="btn" onclick="submitVerification()">Genera &amp; Attiva Badge</button>
      <button class="btn secondary" onclick="closeModal()">Chiudi</button>
      <div id="modalStatus" class="kv" style="margin-top:10px;"></div>
    </div>
  </div>

  <script>
    const RANKS_META = {
      mistress: { label: "Mistress / Sovereign", toy: "Crop & Stiletto Heel (Cartoon)" },
      slave: { label: "Slave / Devoted", toy: "Collar & Soft Cuffs (Cartoon)" },
      front_man: { label: "Front Man / Creator 18+", toy: "Neon Mic & Whip (Cartoon)" },
      holder: { label: "Holder (>20€ pump.fun / $OV / $DSN)", toy: "Vault & Golden Toy (Cartoon)" },
      curioso: { label: "Curioso", toy: "Mask & Toy Key (Cartoon)" },
      ospite: { label: "Ospite", toy: "Magnifier & Half-Lock (Cartoon)" }
    };

    function openModal() { document.getElementById("verifyModal").classList.add("open"); }
    function closeModal() { document.getElementById("verifyModal").classList.remove("open"); }

    async function loadAggregator() {
      try {
        const res = await fetch("/nexus/api/aggregator");
        if (!res.ok) return;
        const json = await res.json();
        const d = json.data || {};
        if (d.zswap_bridge && d.zswap_bridge.url) {
          document.getElementById("zswapLink").href = d.zswap_bridge.url;
        }
        if (d.mistress_legal_finance) {
          const lf = d.mistress_legal_finance;
          document.getElementById("legalBox").innerHTML =
            "<strong>18+ &amp; Consenso:</strong> " + lf.legal.consent_model + "<br/>" +
            "<strong>Anti-Leak / Anti-Doxxing:</strong> " + lf.legal.anti_doxxing_no_leak + "<br/>" +
            "<strong>Separazione Cassa:</strong> " + lf.finance.treasury_segregation + "<br/>" +
            "<strong>Nota:</strong> " + lf.legal.disclaimer;
        }
        if (d.ov_stacks && Array.isArray(d.ov_stacks.tiers)) {
          document.getElementById("stacksBox").innerHTML = d.ov_stacks.tiers.map(t =>
            "<div>• <strong>" + t.label + "</strong> (min " + t.min_eur_equivalent + "€) — Boost Merito: " + t.merit_boost + "</div>"
          ).join("");
        }
      } catch (_) {}
    }

    async function submitVerification() {
      const rank = document.getElementById("rankSelect").value;
      const sender = document.getElementById("senderInput").value.trim();
      const code4 = document.getElementById("code4Input").value.trim().toUpperCase();
      const oathAccepted = document.getElementById("oathCheck").checked;
      const st = document.getElementById("modalStatus");

      if (!oathAccepted) {
        st.textContent = "Devi confermare il Triplice Giuramento (18+, Devozione, Onestà).";
        return;
      }

      const meta = RANKS_META[rank] || RANKS_META.curioso;
      document.getElementById("rankLabel").textContent = meta.label;
      document.getElementById("toyLabel").textContent = meta.toy;

      const finalCode = (code4.length === 4) ? code4 : "VEXA";
      document.getElementById("globalId").textContent = "OV-" + finalCode + "-VELVET";
      document.getElementById("verifyBadge").textContent = "✕$ " + finalCode;
      document.getElementById("zswapLink").href =
        "https://swap.x-zdos.it/?source=velvet&rank=" + encodeURIComponent(rank) + "&entry_eur=2&anchor_eur=0.01";

      try {
        const r = await fetch("/nexus/api/verify-payment-2eur", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ senderWallet: sender, rank, oathAccepted })
        });
        const out = await r.json();
        if (out.ok) {
          document.getElementById("globalId").textContent = out.globalId || ("OV-" + finalCode + "-VELVET");
          st.textContent = "Attivato! ID: " + (out.globalId || finalCode) + " · Gateway: " + (out.badge?.deliveredViaWhatsapp || "+447742507902");
        } else {
          st.textContent = out.error || "Verifica locale applicata.";
        }
      } catch (_) {
        st.textContent = "Card aggiornata localmente con codice " + finalCode + ".";
      }
    }

    loadAggregator();
  </script>
</body>
</html>
"""

for target in [os.path.join(WEB_DIR, "lodge-card.html"), os.path.join(REPO_DIR, "lodge-card.html")]:
    with open(target, "w", encoding="utf-8") as f:
        f.write(html_content)
    print("✅ Salvato:", target)

if os.path.isdir(os.path.join(REPO_DIR, ".git")):
    subprocess.run(["git", "config", "--global", "--add", "safe.directory", "*"], check=False)
    subprocess.run(["git", "-C", REPO_DIR, "add", "-A"], check=False)
    diff = subprocess.run(["git", "-C", REPO_DIR, "diff", "--cached", "--quiet"])
    if diff.returncode != 0:
        subprocess.run(
            ["git", "-C", REPO_DIR, "commit", "-m", "feat(frontend): add lodge interactive card, 4-letter popup, $OV stacks, zswap link and mistress legal/finance view"],
            check=False,
        )
        push = subprocess.run(["git", "-C", REPO_DIR, "push", "origin", "main"])
        if push.returncode != 0:
            print("⚠️ Commit locale completato; verifica credenziali git push se richiesto.")
    else:
        print("ℹ️ Nessuna nuova modifica da committare.")

print("\n✅ FRONT-END DELLA LOGGIA DISTRIBUITO!")
