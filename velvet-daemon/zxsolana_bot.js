try { process.loadEnvFile("/root/velvet-daemon/.env"); } catch (_) {}

const {
  Client,
  GatewayIntentBits,
  EmbedBuilder,
  ActionRowBuilder,
  ButtonBuilder,
  ButtonStyle,
  PermissionFlagsBits,
  ChannelType
} = require("discord.js");

const TOKEN = (process.env.DISCORD_ZXSOLANA_TOKEN || process.env.DISCORD_TOKEN || "").trim();
const NEXUS_URL = "http://127.0.0.1:8899";
const PORTAL_URL = "https://velvet.x-zdos.it/";
const RUBINA_WALLET = "6C61wDacAtx3QHQYVw17fnm5GEaEAnc1XienNJKn2bsD";

const BDSM_HIERARCHY = {
  MISTRESS_SUPREMA: { name: "👑 Mistress Suprema · Loggia BDSM (NSWT-T)", colors: 0xe5e4e2, admin: true },
  MASTER_SOVEREIGN: { name: "⚡ Master Sovereign · Architetto ZDOS", colors: 0x9945ff, admin: true },
  AGI_NODE:         { name: "🤖 Nodo AGI · Velvet & z-xSOLANA Core", colors: 0x00e5ff, admin: false },
  MISTRESS:         { name: "🔥 Mistress della Loggia 18+", colors: 0xc41e3a, admin: false },
  MASTER:           { name: "⛓️ Master & Dom 18+", colors: 0x8b0000, admin: false },
  SLAVE:            { name: "🩸 Slave · Sottomesso Verificato 18+", colors: 0x4a0404, admin: false }
};

const client = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages]
});

client.once("clientReady", (c) => {
  console.log(`[lil'kali / z-xSOLANA] Connesso come ${c.user.tag}! Tutti i moduli attivi.`);
  c.user.setPresence({
    activities: [{ name: "💎 La Loggia BDSM // $OV Badge & AGI", type: 3 }],
    status: "online"
  });
});

async function ensureRole(guild, spec, isAdmin = false) {
  let role = guild.roles.cache.find((r) => r.name === spec.name);
  const perms = isAdmin ? [PermissionFlagsBits.Administrator] : [];
  if (!role) {
    role = await guild.roles.create({
      name: spec.name,
      colors: spec.colors,
      hoist: true,
      mentionable: true,
      permissions: perms
    });
  }
  return role;
}

client.on("messageCreate", async (message) => {
  if (message.author.bot) return;
  const cleaned = message.content.replace(new RegExp(`^<@!?${client.user.id}>\\s*`, "i"), "").trim();
  const parts = cleaned.split(/\s+/);
  const cmd = (parts[0] || "").toLowerCase().replace(/^!/, "");

  if (cmd === "badge_giftrubina" || cmd === "regala_badge") {
    const targetWallet = (parts[1] && parts[1].length >= 32) ? parts[1].trim() : RUBINA_WALLET;
    try {
      const r = await fetch(`${NEXUS_URL}/api/nft/badge/${encodeURIComponent(targetWallet)}.json`);
      const b = await r.json();
      const embed = new EmbedBuilder()
        .setColor(0xc41e3a)
        .setTitle("💎 EROGAZIONE: $OV SUPER BADGE GIFT ULTRA NFT")
        .setDescription(
          `Decreto di <@${message.author.id}> eseguito.\n\n` +
          `**TITOLARE:** ${b.memberTag || "Rubina · Mistress Suprema"}\n` +
          `**RUOLO ASSEGNATO:** Mistress Ultra · Platinum Supremo (NSWT-T)\n` +
          `**ID CERTIFICATO:** \`${b.id || "VC18-RUBINA-NSWT"}\`\n` +
          `**WALLET:** \`${targetWallet.slice(0, 6)}...${targetWallet.slice(-6)}\`\n` +
          `**SALDO $OV:** \`999.999,99 $OV\``
        )
        .setImage(`https://velvet.x-zdos.it/api/nft/badge/${encodeURIComponent(targetWallet)}.svg?t=${Date.now()}`)
        .setFooter({ text: "OurVelvet & La Loggia BDSM · ZDOS · Solo 18+ · Safeword: ROSSO" });

      const row = new ActionRowBuilder().addComponents(
        new ButtonBuilder().setLabel("Apri Badge Rubina").setStyle(ButtonStyle.Link).setURL("https://velvet.x-zdos.it/badge"),
        new ButtonBuilder().setLabel("Genera Pass & NFT Phantom").setStyle(ButtonStyle.Link).setURL("https://velvet.x-zdos.it/pass")
      );

      await message.reply({ embeds: [embed], components: [row] });
      await message.channel.send(`🎉 **DECRETO ESEGUITO!** Il Super Badge Gift Ultra NFT è stato consegnato a **${b.memberTag || "Rubina"}**. Benvenuta nella piena sovranità, Mistress!`);
    } catch (e) {
      await message.reply(`⚠️ Errore Nexus: ${e.message}`);
    }
    return;
  }

  if (["attiva_tutto", "setup_loggia", "setup_admin"].includes(cmd)) {
    const guild = message.guild;
    if (!guild) return;
    const roles = {};
    for (const [k, spec] of Object.entries(BDSM_HIERARCHY)) {
      roles[k] = await ensureRole(guild, spec, Boolean(spec.admin)).catch(() => null);
    }
    const targets = [];
    if (message.member) targets.push(message.member);
    for (const [id, u] of message.mentions.users) {
      if (!u.bot && id !== message.author.id) {
        const m = await guild.members.fetch(id).catch(() => null);
        if (m) targets.push(m);
      }
    }
    for (const m of targets) {
      if (roles.MISTRESS_SUPREMA) await m.roles.add(roles.MISTRESS_SUPREMA).catch(() => {});
      if (roles.MASTER_SOVEREIGN) await m.roles.add(roles.MASTER_SOVEREIGN).catch(() => {});
    }
    for (const [, m] of guild.members.cache) {
      if (m.user.bot && roles.AGI_NODE) await m.roles.add(roles.AGI_NODE).catch(() => {});
    }
    return message.reply(`👑 **ATTIVAZIONE COMPLETATA!** Ruoli supremi assegnati a ${targets.map(t => `<@${t.id}>`).join(", ")} e Nodi AGI sincronizzati.`);
  }

  if (["presenta_id", "post_id", "lancia_benvenuto"].includes(cmd)) {
    const embed = new EmbedBuilder()
      .setColor(0x8b0000)
      .setTitle("🩸 OURVELVET & LA LOGGIA BDSM // ID GLOBALE 18+ & BADGE NFT")
      .setDescription(
        "Ottieni il tuo **ID Globale Verificato (`VC18`)** e invia la **NFT Card Badge** nel tuo wallet Phantom:\n" +
        "👉 **https://velvet.x-zdos.it/pass**\n\n" +
        "🎭 **Reagisci qui sotto:** 👑 Mistress · ⚡ Master · ⛓️ Slave · 🔥 Creator · 💎 Holder $OV"
      );
    const row = new ActionRowBuilder().addComponents(
      new ButtonBuilder().setLabel("Ottieni ID & NFT Phantom").setStyle(ButtonStyle.Link).setURL("https://velvet.x-zdos.it/pass"),
      new ButtonBuilder().setLabel("Badge Rubina").setStyle(ButtonStyle.Link).setURL("https://velvet.x-zdos.it/badge")
    );
    const sent = await message.channel.send({ content: "@everyone 🌹 **PRESENTAZIONE UFFICIALE OURVELVET & LA LOGGIA BDSM**", embeds: [embed], components: [row] });
    for (const e of ["👑", "⚡", "⛓️", "🔥", "💎"]) await sent.react(e).catch(() => {});
    return;
  }

  if (cmd === "pass" && parts[1]) {
    const wallet = parts[1].trim();
    const r = await fetch(`${NEXUS_URL}/api/access/badge`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ wallet })
    });
    const b = await r.json();
    if (!b.ok || !b.found) return message.reply(`❌ Nessun pass trovato per \`${wallet}\`. Registrati su https://velvet.x-zdos.it/pass`);
    return message.reply(`👑 **PASS CERTIFICATO:** \`${b.tier}\` · Tag: **${b.memberTag}** · ID: \`${b.id}\``);
  }

  if (cmd === "saldo" && parts[1]) {
    const wallet = parts[1].trim();
    const r = await fetch(`${NEXUS_URL}/api/solana/balances`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ wallet })
    });
    const d = await r.json();
    if (!d.ok) return message.reply(`❌ Errore wallet: ${d.error}`);
    return message.reply(`💎 **SALDO:** \`${Number(d.sol || 0).toFixed(4)} SOL\` · \`${Number(d.ov || 0).toFixed(2)} $OV\` · \`${Number(d.dsn || 0).toFixed(2)} $DSN\``);
  }
});

client.login(TOKEN);
