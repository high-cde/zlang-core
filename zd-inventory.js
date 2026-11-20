// Inventario sola lettura del server (REST, nessun gateway). Token da env, mai stampato.
const { createRequire } = require('module'); const rq = createRequire('/opt/zdiscord/package.json');
const { REST, Routes } = rq('discord.js');
const G = process.argv[2];
const rest = new REST({ version: '10' }).setToken(process.env.DISCORD_TOKEN);
const ts = (id) => id ? new Date(Number((BigInt(id) >> 22n) + 1420070400000n)).toISOString() : null;
(async () => {
  const chans = await rest.get(Routes.guildChannels(G));
  const invites = await rest.get(Routes.guildInvites(G)).catch((e) => ({ err: e.message }));
  const integ = await rest.get(Routes.guildIntegrations(G)).catch((e) => ({ err: e.message }));
  const roles = await rest.get(Routes.guildRoles(G));
  const out = [];
  for (const c of chans) {
    const o = { id: c.id, name: c.name, type: c.type, parent: c.parent_id, pos: c.position, nsfw: !!c.nsfw, topic: c.topic || '', created: ts(c.id), lastId: c.last_message_id || null, last: ts(c.last_message_id), ow: (c.permission_overwrites || []).length, everyoneDenyView: (c.permission_overwrites || []).some((x) => x.id === G && (BigInt(x.deny) & (1n << 10n))) };
    if ([0, 5].includes(c.type) && c.last_message_id) {
      try { const m = await rest.get(Routes.channelMessages(c.id), { query: new URLSearchParams({ limit: '5' }) }); o.recent = m.map((x) => ({ bot: !!x.author.bot, author: x.author.username, at: x.timestamp.slice(0, 10) })); } catch (e) { o.recentErr = e.status || e.message; }
    }
    out.push(o);
  }
  console.log(JSON.stringify({ chans: out, invites: Array.isArray(invites) ? invites.map((i) => ({ code: i.code, ch: i.channel && i.channel.name, chId: i.channel && i.channel.id, maxAge: i.max_age, uses: i.uses, inviter: i.inviter && i.inviter.username })) : invites, integ: Array.isArray(integ) ? integ.map((i) => ({ name: i.name, type: i.type, bot: i.application && i.application.bot && i.application.bot.username })) : integ, roles: roles.map((r) => ({ id: r.id, name: r.name, pos: r.position, managed: r.managed })) }));
})().catch((e) => { console.error('ERR', e.message); process.exit(1); });
