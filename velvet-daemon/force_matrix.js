const { Client, GatewayIntentBits, ChannelType } = require('discord.js');

const client = new Client({
    intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages, GatewayIntentBits.MessageContent]
});

const TOKEN = "MTU3MjMwMTI1MTk4MTYxMTA4OA.G_zI9O.OPRwM6DOPNO3hV-IS54Re52oCakwEbS7-ftEns";
const GUILD_ID = "1080897680689070160";

client.once('clientReady', async (c) => {
    console.log(`[Z-CORE FORCE BUILD] Connesso come ${c.user.tag}. Creazione forzata della matrice...`);
    
    try {
        const guild = await client.guilds.fetch(GUILD_ID);

        // Struttura imperiale completa da creare
        const structure = [
            {
                name: '🕯️ 1. KERNEL GATEWAY',
                channels: ['colloquio-iniziazione', 'annunci-globali', 'last-minute-drops', 'open-ticket-support', 'waiting-room-lobby']
            },
            {
                name: '⚡ 2. ZDOS KERNEL & ZLANG',
                channels: ['main-terminal-log', 'zlang-ide-gateway', 'zdos-distro-builds', 'github-repos-zc', 'zlang-and-baremetal']
            },
            {
                name: '💎 3. SOLANA TOKENOMICS',
                channels: ['dsn-ov-token-hub', 'swap-gateway-zswap', 'phantom-wallet-safe', 'airdrop-and-staking']
            },
            {
                name: '🌷 4. AMSTERDAM RED LIGHT',
                channels: ['amsterdam-red-light-hub', 'prenotazione-camere-private', 'rubina-e-companion-suites', 'de-wallen-window-district']
            },
            {
                name: '💋 5. VELVETHUB SUITES 18+',
                channels: ['velvethub-portal', 'forum-discussioni-gilda', 'vip-membership-and-passes', 'explicit-adult-previews', 'live-cam-and-private-booths', 'mance-e-tributi-vip']
            },
            {
                name: '🌹 6. VELVET DOMINANCE',
                channels: ['trono-delle-padrone', 'galleria-delle-dom', 'cassa-tributi-dom', 'gabbia-schiavi-registrazione', 'compiti-e-servizi-schiavi', 'passerella-schiavi', 'gogna-e-punizioni', 'cuccia-schiave-e-pets', 'oggettificazione-e-decoro', 'prove-di-devozione', 'sissy-training-academy', 'passerella-sissy-e-vetrina', 'lock-and-chastity-sissy', 'human-toilet-zone', 'scarico-e-umiliazione-liquida', 'pasti-da-schiavo', 'arena-contest-e-gare', 'gogna-pubblica-umiliazioni', 'hall-of-shame-trofei']
            },
            {
                name: '🎙️ 7. PODCAST & TELEGRAM',
                channels: ['telegram-mini-app-bot', 'podcast-e-voice-masterclass', 'dark-abyss-voice']
            },
            {
                name: '🔥 8. RAW CAKE & RPG',
                channels: ['meat-radar-game-hub', 'booty-and-pussy-drops', 'hardcore-cocks-and-girth', 'cum-tributes-and-facials']
            },
            {
                name: '⛓️ 9. HARDCORE KINK',
                channels: ['ropes-and-bondage', 'heels-leather-worship', 'plugs-toys-torture']
            },
            {
                name: '🛡️ 10. STAFF OPERATIONS',
                channels: ['staff-command-room', 'zdos-sysops-log', 'security-and-kira-ai', 'audit-tributi-ov']
            }
        ];

        for (const cat of structure) {
            const categoryChannel = await guild.channels.create({
                name: cat.name,
                type: ChannelType.GuildCategory,
            });
            console.log(`[+] Categoria creata: ${cat.name}`);

            for (const chName of cat.channels) {
                await guild.channels.create({
                    name: chName,
                    type: ChannelType.GuildText,
                    parent: categoryChannel.id,
                });
                console.log(`    [->] Canale creato: #${chName}`);
            }
        }

        console.log('[👑] Matrice imperiale creata con successo!');
        process.exit(0);
    } catch (err) {
        console.error('[x] Errore:', err);
        process.exit(1);
    }
});

client.login(TOKEN);
