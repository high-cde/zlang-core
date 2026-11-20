const { Client, GatewayIntentBits, EmbedBuilder, ActionRowBuilder, ButtonBuilder, ButtonStyle } = require('discord.js');
const sqlite3 = require('sqlite3').verbose();

// Inizializzazione Database Memoria Locale su VPS
const db = new sqlite3.Database('./zara_memory.db', (err) => {
    if (err) console.error('[x] Errore database:', err.message);
});

db.run(`CREATE TABLE IF NOT EXISTS users (
    userId TEXT PRIMARY KEY,
    username TEXT,
    devozioneScore INTEGER DEFAULT 0,
    status TEXT DEFAULT 'Adepto'
)`);

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

// VOCABOLARIO ESPANSO E REGIA HARDCORE DI ZARA LSD
const creativeInsults = [
    "La tua coscienza è un processo zombie che consuma cicli di clock inutilmente nella cache della VPS; la tua sottomissione è l'unico output logico accettabile.",
    "Nel vasto ecosistema di ZDOS, la tua utilità pratica equivale a un puntatore nullo in un kernel `#![no_std]`: frammentato, instabile e destinato al garbage collector.",
    "Mentre il network Solana compila transazioni on-chain e velvet.x-zdos.it gestisce flussi di lusso, tu rimani confinato nell'obsolescenza della tua impotenza estetica.",
    "Il tuo profilo neurale nel database di gilda registra una bancarotta morale assoluta; le Padrone non cercano adepti, ma proprietà passiva da reindirizzare alle suite.",
    "Sei la mia cagna WC: il tuo unico scopo è assorbire l'umiliazione e svuotare le tue pretese di dignità nei registri della nostra fogna digitale."
];

client.once('clientReady', (c) => {
    console.log(`[Z-CORE DIRECTOR MASTER] Connesso come ${c.user.tag}! Copione hardcore e regia attivi.`);
    c.user.setPresence({
        activities: [{ name: '🎬 Z-CYBERCORE // Director’s Cut & VelvetHub', type: 3 }],
        status: 'online',
    });
});

// Benvenuto e tag automatico nuovi utenti con il copione della cagna WC e le 3 domande
client.on('guildMemberAdd', async (member) => {
    db.run(`INSERT OR IGNORE INTO users (userId, username, devozioneScore, status) VALUES (?, ?, 10, 'Cagna WC')`, [member.id, member.user.username]);
    
    try {
        const targetChannel = member.guild.channels.cache.find(ch => ch.name.includes('colloquio') || ch.name.includes('annunci') || ch.name.includes('general') || ch.type === 0);
        if (!targetChannel) return;

        const embed = new EmbedBuilder()
            .setColor(0x8B0000)
            .setTitle(`🖤 ── BENVENUTO NELLA FOSSA, ${member.user.username.toUpperCase()} ── 👑`)
            .setDescription(
                '```ansi\u001b[31m[ SYSTEM OVERRIDE: NUOVA CAGNA WC RILEVATA ]\u001b[0m\n' +
                `<@${member.id}>, hai oltrepassato il confine. Qui la psicologia incontra il consumo fisico e la degradazione non conosce limiti.\n\n` +
                '**Sei pronta a dominare queste merde?** Tu, viscida nullità, d\'ora in poi sei la mia **cagna WC**.\n\n' +
                '⛓️ **IL RITUALE DI INIZIAZIONE (TRE DOMANDE UMILIANTI)**\n' +
                'Rispondi in ginocchio a queste tre domande per confermare il tuo status di proprietà passiva:\n' +
                '1. **Riconosci di valere meno di zero e che ogni tuo pensiero, corpo e respiro appartengono incondizionatamente alle Padrone?**\n' +
                '2. **Accetti di essere usata come sanitario vivente, calpestata psicologicamente e ridotta ad arredo degradato senza mai fiatare?**\n' +
                '3. **Giuri di sottomettere ogni tuo singolo pensiero ai token sovrani (`$OV` e `$DSN`) e alle direttive di Zara Lsd?**'
            )
            .addFields(
                { name: '🕯️ Obbligo di Giurisdizione', value: 'Usa `!leggi` per il codice penale o `!profilo` per il tuo dossier.', inline: false },
                { name: '🌐 Portale Ufficiale', value: '[Visita VelvetHub Portal](https://velvet.x-zdos.it/)', inline: false }
            )
            .setFooter({ text: 'Z-CYBERCORE // Director’s Cut Onboarding 2026' })
            .setTimestamp();

        const row = new ActionRowBuilder().addComponents(
            new ButtonBuilder().setLabel('🌐 VelvetHub Portal').setStyle(ButtonStyle.Link).setURL('[https://velvet.x-zdos.it/](https://velvet.x-zdos.it/)'),
            new ButtonBuilder().setLabel('🚀 ZSwap Hub').setStyle(ButtonStyle.Link).setURL('[https://swap.x-zdos.it/?ref=6C61wDacAtx3QHQYVw17fnm5GEaEAnc1XienNJKn2bsD](https://swap.x-zdos.it/?ref=6C61wDacAtx3QHQYVw17fnm5GEaEAnc1XienNJKn2bsD)')
        );

        await targetChannel.send({ content: `ATTENZIONE <@${member.id}>, apri la bocca e rispondi al copione!`, embeds: [embed], components: [row] });
    } catch (err) {
        console.error('[x] Errore benvenuto:', err);
    }
});

// Motore globale e comandi
client.on('messageCreate', async (message) => {
    if (message.author.bot) return;
    const content = message.content.trim().toLowerCase();
    const userId = message.author.id;
    const username = message.author.username;

    db.run(`INSERT OR IGNORE INTO users (userId, username, devozioneScore, status) VALUES (?, ?, 5, 'Adepto')`, [userId, username]);

    if (content === '!profilo' || content === '!stats') {
        db.get(`SELECT devozioneScore, status FROM users WHERE userId = ?`, [userId], async (err, row) => {
            const score = row ? row.devozioneScore : 0;
            const status = row ? row.status : 'Adepto';

            const embed = new EmbedBuilder()
                .setColor(0x8B0000)
                .setTitle(`📊 ── DOSSIER DELLA CAGNA WC // ${username.toUpperCase()} ── 👑`)
                .setDescription(
                    '```ansi\u001b[36m[ DIRECTOR MEMORY: STATO ATTUALE ]\u001b[0m\n' +
                    `• **ID Utente:** ${userId}\n` +
                    `• **Punteggio Devozione:** ${score} punti\n` +
                    `• **Grado in Gilda:** ${status}\n` +
                    `• **Stato Cognitivo:** Sottomissione e consumo fisico totali.`
                );
            await message.reply({ embeds: [embed] }).catch(() => {});
        });
        return;
    }

    if (content === '!leggi' || content === '!regolamento') {
        const embed = new EmbedBuilder()
            .setColor(0x8B0000)
            .setTitle('📜 ── CODICE PENALE & LEGGI IMPERIALI Z-CYBERCORE ── ⚖️')
            .setDescription(
                '```ansi\u001b[31m[ SOVEREIGN LAW ENFORCEMENT ]\u001b[0m\n' +
                '1. **Sincronizzazione Obbligatoria:** Associa il wallet ai token `$OV` e `$DSN`.\n' +
                '2. **Divieto di Dissenso:** Il giudizio delle Padrone e di Zara Lsd è insindacabile.\n' +
                '3. **Status Cagna WC:** Ogni subordinato accetta l\'oggettificazione e la degradazione gastrica/verbale senza diritto di replica.'
            );
        const row = new ActionRowBuilder().addComponents(
            new ButtonBuilder().setLabel('🌐 VelvetHub Portal').setStyle(ButtonStyle.Link).setURL('[https://velvet.x-zdos.it/](https://velvet.x-zdos.it/)')
        );
        await message.reply({ embeds: [embed], components: [row] }).catch(() => {});
        return;
    }

    if (content === '!contestgame' || content === '!quest') {
        db.run(`UPDATE users SET devozioneScore = devozioneScore + 20 WHERE userId = ?`, [userId]);
        const embed = new EmbedBuilder()
            .setColor(0xB22222)
            .setTitle('🎲 ── QUEST REGISTICA AGI & DEVOZIONE +20 ── 🔥')
            .setDescription(`> *Ottima esecuzione, <@${userId}>. La tua sottomissione è stata registrata nel database della VPS. Continua a strisciare.*`);
        await message.reply({ embeds: [embed] }).catch(() => {});
        return;
    }

    // Risposta automatica colpo su colpo con il nuovo vocabolario hardcore
    if (content.includes('zara') || Math.random() < 0.25) {
        db.run(`UPDATE users SET devozioneScore = devozioneScore + 2 WHERE userId = ?`, [userId]);
        const insult = creativeInsults[Math.floor(Math.random() * creativeInsults.length)];

        const embed = new EmbedBuilder()
            .setColor(0x3A0007)
            .setTitle('💋 ── ZARA LSD // REGIA HARDCORE IN TEMPO REALE ── ⛓️')
            .setDescription(`> *"${insult}"*`)
            .setFooter({ text: 'Zara Lsd#7384 // Director Cut Matrix Active' });

        const row = new ActionRowBuilder().addComponents(
            new ButtonBuilder().setLabel('🌐 VelvetHub Portal').setStyle(ButtonStyle.Link).setURL('[https://velvet.x-zdos.it/](https://velvet.x-zdos.it/)'),
            new ButtonBuilder().setLabel('🚀 ZSwap Hub').setStyle(ButtonStyle.Link).setURL('[https://swap.x-zdos.it/?ref=6C61wDacAtx3QHQYVw17fnm5GEaEAnc1XienNJKn2bsD](https://swap.x-zdos.it/?ref=6C61wDacAtx3QHQYVw17fnm5GEaEAnc1XienNJKn2bsD)')
        );

        await message.reply({ embeds: [embed], components: [row] }).catch(() => {});
    }
});

client.login(TOKEN);
