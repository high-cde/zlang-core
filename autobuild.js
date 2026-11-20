const { Client, GatewayIntentBits, ChannelType } = require('discord.js');

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
    ]
});

// Token del bot inserito direttamente
const TOKEN = "MTU3MjMwMTI1MTk4MTYxMTA4OA.Gqewku.s9SRMuTiXSP2F8Nnc4M4dGTAmSSAs6FvdW9L7c";
const GUILD_ID = '1572271944269692999';

client.once('ready', async () => {
    console.log(`[K.I.R.A. AGI] Bot connected as ${client.user.tag}. Deploying Autobuild Master Tree...`);

    try {
        const guild = await client.guilds.fetch(GUILD_ID);
        if (!guild) {
            console.error('[ERROR] Guild not found:', GUILD_ID);
            process.exit(1);
        }

        const masterTreeFull = [
            {
                name: '🕯️ ── ONBOARDING & INIZIAZIONE ──',
                channels: [
                    { name: 'colloquio-iniziazione', type: ChannelType.GuildText }
                ]
            },
            {
                name: '💎 ── $OV TOKEN & WEB3 VAULT ──',
                channels: [
                    { name: 'ov-token-hub', type: ChannelType.GuildText },
                    { name: 'contract-mints', type: ChannelType.GuildText },
                    { name: 'phantom-connect-safe', type: ChannelType.GuildText },
                    { name: 'ov-faucet-bot', type: ChannelType.GuildText }
                ]
            },
            {
                name: '🔥 ── GENERATOR, CONTESTS & DROPS ──',
                channels: [
                    { name: 'generator-creations-feed', type: ChannelType.GuildText },
                    { name: 'latex-and-flesh-contest', type: ChannelType.GuildText },
                    { name: 'contest-scores-and-votes', type: ChannelType.GuildText },
                    { name: 'pleasure-auctions-board', type: ChannelType.GuildText },
                    { name: 'nsfw-giveaways', type: ChannelType.GuildText }
                ]
            },
            {
                name: '🔥 ── RAW CAKE & NSFW VAULT ──',
                channels: [
                    { name: 'booty-and-pussy-drops', type: ChannelType.GuildText },
                    { name: 'hardcore-cocks-and-girth', type: ChannelType.GuildText },
                    { name: 'cum-tributes-and-facials', type: ChannelType.GuildText }
                ]
            },
            {
                name: '⛓️ ── HARDCORE KINK & FETISH ──',
                channels: [
                    { name: 'ropes-and-bondage', type: ChannelType.GuildText },
                    { name: 'heels-leather-worship', type: ChannelType.GuildText },
                    { name: 'plugs-toys-torture', type: ChannelType.GuildText },
                    { name: 'pain-and-pleasure-play', type: ChannelType.GuildText }
                ]
            },
            {
                name: '🎮 ── ADULT HENTAI & GAMING ──',
                channels: [
                    { name: 'nsfw-game-releases', type: ChannelType.GuildText },
                    { name: 'adult-play-room', type: ChannelType.GuildText }
                ]
            },
            {
                name: '📺 ── MEDIA & PODCAST HUB ──',
                channels: [
                    { name: 'velvet-podcasts', type: ChannelType.GuildText },
                    { name: 'clips-and-teasers', type: ChannelType.GuildText },
                    { name: 'third-party-news-feed', type: ChannelType.GuildText }
                ]
            },
            {
                name: '🛍️ ── SMARTSHOP & TOYS ──',
                channels: [
                    { name: 'live-shopify-smartshop', type: ChannelType.GuildText }
                ]
            },
            {
                name: '💬 ── COMMUNITY LOUNGE ──',
                channels: [
                    { name: 'general-nsfw-forum', type: ChannelType.GuildForum },
                    { name: 'chill-and-lore', type: ChannelType.GuildText }
                ]
            },
            {
                name: '⛓️ ── DOM & SUB PALACE ──',
                channels: [
                    { name: 'mistress-master-command', type: ChannelType.GuildText },
                    { name: 'submissive-slaves-floor', type: ChannelType.GuildText }
                ]
            },
            {
                name: '🤖 ── AI STAGE & CUMTROL ──',
                channels: [
                    { name: 'rubina-ai-dungeon', type: ChannelType.GuildText }
                ]
            },
            {
                name: '🛡️ ── STAFF & CORE OPS ──',
                channels: [
                    { name: 'lil-kali-conclave', type: ChannelType.GuildText },
                    { name: 'vps-pm2-terminal', type: ChannelType.GuildText },
                    { name: 'staff-briefing', type: ChannelType.GuildText }
                ]
            },
            {
                name: '📼 ── STUDIO, STREAM & VOICE ──',
                channels: [
                    { name: 'ai-horde-studio', type: ChannelType.GuildText },
                    { name: 'verified-4k-library', type: ChannelType.GuildText },
                    { name: 'dark-abyss-voice', type: ChannelType.GuildVoice }
                ]
            }
        ];

        for (const cat of masterTreeFull) {
            console.log(`[+] Creating category: ${cat.name}`);
            const categoryChannel = await guild.channels.create({
                name: cat.name,
                type: ChannelType.GuildCategory,
            });

            for (const ch of cat.channels) {
                console.log(`    |_ Creating channel: #${ch.name}`);
                await guild.channels.create({
                    name: ch.name,
                    type: ch.type,
                    parent: categoryChannel.id,
                });
            }
        }

        console.log('[OK] Autobuild completed successfully! Server structure deployed.');
        process.exit(0);

    } catch (err) {
        console.error('[CRITICAL ERROR] Autobuild failed:', err);
        process.exit(1);
    }
});

client.login(TOKEN);
