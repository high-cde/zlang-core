const { default: makeWASocket, useMultiFileAuthState, fetchLatestBaileysVersion } = require("@whiskeysockets/baileys");
const pino = require("pino");

const PHONE = "393501724159";
const SECURITY_NOTICE =
  "🖤 *PROTOCOLLO DI SICUREZZA // OUR VELVET & ZDOS* 🖤\n\n" +
  "Sistema di protezione attivo. L'accesso e la permanenza nella Loggia sono subordinati a reale autenticazione.\n\n" +
  "📢 *Canale Ufficiale 18+:* https://whatsapp.com/channel/0029Vb9Rbee89inrYLhdem1n\n" +
  "🗝️ *Portale Verifica & Identità $OV:* https://velvet.x-zdos.it\n\n" +
  "👉 Digita `!forge` per generare la tua Identità Globale `$OV` o `!velvet` per i comandi.\n" +
  "_Build what you can prove._ ⚡";

async function run() {
  const { state, saveCreds } = await useMultiFileAuthState("./auth");
  const { version } = await fetchLatestBaileysVersion();
  const sock = makeWASocket({
    version,
    auth: state,
    logger: pino({ level: "silent" }),
    browser: ["Ubuntu", "Chrome", "20.0.04"]
  });

  sock.ev.on("creds.update", saveCreds);

  if (!sock.authState.creds.registered) {
    setTimeout(async () => {
      const code = await sock.requestPairingCode(PHONE);
      console.log("\n==========================================");
      console.log("🔑 CODICE WHATSAPP (INSERISCI ORA):", code);
      console.log("==========================================\n");
    }, 3000);
  }

  sock.ev.on("connection.update", async ({ connection }) => {
    if (connection === "open") {
      console.log("✅ CONNESSO A WHATSAPP!");
      const groups = await sock.groupFetchAllParticipating();
      for (const [gid, meta] of Object.entries(groups)) {
        if (meta.subject.includes("Velvet Lodge") || meta.subject.includes("Nova Community")) {
          await sock.sendMessage(gid, { text: SECURITY_NOTICE });
          console.log("🚀 Messaggio di sicurezza sparato in:", meta.subject);
        }
      }
    }
  });
}
run();
