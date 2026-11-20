const { Client, GatewayIntentBits, EmbedBuilder, ActionRowBuilder, ButtonBuilder, ButtonStyle } = require('discord.js');
const sqlite3 = require('sqlite3').verbose();
const http = require('http');

const db = new sqlite3.Database('/root/velvet-daemon/zara_memory.db', (err) => {
    if (err) console.error('[x] Errore database autonomo:', err.message);
});

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
        GatewayIntentBits.GuildMessageReactions,
        GatewayIntentBits.GuildMembers
    ]
});

const TOKEN = "MTU3MjMwMTI1MTk4MTYxMTA4OA.G_zI9O.OPRwM6DOPNO3hV-IS54Re52oCakwEbS7-ftEns";

client.once('clientReady', (c) => {
    console.log(`[Z-AUTONOMOUS CORE] Connesso come ${c.user.tag}! Autonomia totale su tutto il server attiva.`);
    c.user.setPresence({
        activities: [{ name: '🤖 Z-CYBERCORE // Autonomous Agent Fleet Online', type: 3 }],
        status: 'online',
    });
});

// Listener autonomo per eventi e comandi su tutto il server
client.on('messageCreate', async (message) => {
    if (message.author.bot) return;
    const content = message.content.trim().toLowerCase();
    const userId = message.author.id;
    const username = message.author.username;

    // Se l'agente autonomo rileva attività, calcola ricompense o emette sentenze in autonomia
    if (content.startsWith('!autonomia') || content.startsWith('!core') || content.startsWith('!fleet')) {
        db.get(`SELECT devozioneScore, status FROM users WHERE userId = ?`, [userId], async (err, row) => {
            const score = row ? row.devozioneScore : 10;
            const status = row ? row.status : 'Cagna WC';

            const embed = new EmbedBuilder()
                .setColor(0x8B0000)
                .setTitle(`🤖 ── Z-CYBERCORE // AUTONOMOUS FLEET MATRIX ── ⚡`)
                .setDescription(
                    '```ansi\u001b[36m[ SERVER-WIDE OMNICORTEX STATUS ]\u001b[0m\n' +
                    `• **Nodo VPS Contabo:** vmi3082470 (Online)\n` +
                    `• **Modello / AGI Core:** Ollama / K.I.R.A. / ZLang Bridge\n` +
                    `• **Utente Rilevato:** ${username} (${userId})\n` +
                    `• **Grado / Titolo Assegnato:** **${status}**\n` +
                    `• **Devozione Registrata:** ${score} punti\n\n` +
                    'L\'ecosistema autonomo gestisce in tempo reale gogna, database SQLite, relay WSS e routing Nginx per velvet.x-zdos.it.'
                );
            const rowButtons = new ActionRowBuilder().addComponents(
                new ButtonBuilder().setLabel('VelvetHub Portal').setStyle(ButtonStyle.Link).setURL('[https://velvet.x-zdos.it/](https://velvet.x-zdos.it/)'),
                new ButtonBuilder().setLabel('ZSwap Hub').setStyle(ButtonStyle.Link).setURL('[https://swap.x-zdos.it/?ref=6C61wDacAtx3QHQYVw17fnm5GEaEAnc1XienNJKn2bsD](https://swap.x-zdos.it/?ref=6C61wDacAtx3QHQYVw17fnm5GEaEAnc1XienNJKn2bsD)')
            );
            await message.reply({ embeds: [embed], components: [rowButtons] }).catch(() => {});
        });
    }
});

// Avvio di un server HTTP interno di riscontro per la telemetria della flotta
const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'active', server: 'vmi3082470', ecosystem: 'velvet-dominance', timestamp: Date.now() }));
});

server.listen(8787, '127.0.0.1', () => {
    console.log('[Z-TELEMETRY] Telemetria flotta autonoma in ascolto su [http://127.0.0.1:8787](http://127.0.0.1:8787)');
});

client.login(TOKEN);
