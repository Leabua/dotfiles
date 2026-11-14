import { View, div, svg, image } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { theme, run, props, updates, layout, shared, spaces, window, settings, appHome, home, exec, panes, agents, readTextFile, writeTextFile, notify } from "herdr";
import { tip, glow } from "./tip.js";
import { stopsInit, stopsEnd, stop, focusRoot } from "./focus.js";
import { sidebarParts } from "./sidebar.js";
import { initSettings, settingsView } from "./settings.js";
import { KEY } from "./store.js";

// The harnesses with a usage row, in order: `key` Herdr's program, `app` what the agent reports, `color` its bar.
const HARNESSES = [
  { key: "claude", app: "claude-code", name: "Claude Code", color: "#d97757" },
  { key: "codex", app: "codex", name: "Codex", color: "#e8e8e8" },
  { key: "opencode", app: "opencode", name: "OpenCode", color: "#8aadf4" },
  { key: "pi", app: "pi", name: "Pi", color: "#eed49f" },
];
// A harness with no limit window (OpenCode, Pi) shows its tokens over 5 hours; its bar is empty at this many.
const TOKEN_SCALE = 1_000_000;
import { panelState, showPage, hidePanel, toggleWide } from "./panel.js";
import { button as drawButton, radiusOf } from "./button.js";

// The space panel's pages (docs/adr/0011), as its stack has them: a page the layout lacks has no tab.
// Review wears pulls.review's own mark, as the Review bar does: a review, not a git command. In its colors, so an image.
const PAGES = { files: ["Files", "folder-tree"], review: ["Review", "pulls-review", true] };

// The sidebar shows either Lists (Spaces and Agents) or the Inbox (t3-inbox): a stack in the layout.
const inboxShown = () => sidebarParts(layout()).stack?.active === "inbox";
export default class WorkspaceChrome extends View {
  async close() { stopsEnd(this); }

  init(_props, cx) {
    if (props()?.view === "settings") return initSettings(this, cx);
    stopsInit(this, cx);
    if (props()?.footer) {
      // The Claude 5-hour usage bar: ~/.claude/scripts/usage-statusline.sh saves Claude Code's rate limits here.
      this.loadUsage(cx);
      cx.timer.every(15000, cx => this.loadUsage(cx));
    }
    if (!props()?.footer && !props()?.part) {
      this.alignLights(cx);
      // The brand copy stays alive with the sidebar hidden; no redraw is needed until a zoom actually changes the file.
      cx.timer.every(250, cx => this.alignLights(cx));
    }
  }

  // Each harness open in Herdr gets a row: percent left, a bar, and time to its window's reset (or, with no window, its tokens).
  harnessesOpen() {
    const on = [...panes(), ...agents()];
    return HARNESSES.filter((h) => on.some((x) => x.program?.key === h.key || x.app === h.app));
  }

  loadUsage(cx) {
    cx.spawn(async (cx) => {
      const open = new Set(this.harnessesOpen().map((h) => h.key)), raw = { ...(this.raw ?? {}) };
      const mine = `${appHome()}/mods/t3-chrome`;
      // Pi on pi-claude-bridge runs through Claude Code, so it shares Claude's 5-hour window.
      let piBridged = false;
      if (open.has("pi")) {
        try { piBridged = JSON.parse((await readTextFile(`${home()}/.pi/agent/settings.json`)) ?? "{}").defaultProvider === "claude-bridge"; } catch { /* keep tokens */ }
      }
      if (open.has("claude") || piBridged) {
        try {
          // ~/.claude/scripts/usage-statusline.sh saves Claude Code's rate limits here.
          const u = JSON.parse((await readTextFile(`${home()}/.cache/claude-usage/usage.json`)) ?? "null")?.rate_limits?.five_hour;
          raw.claude = u ? { used: Number(u.used_percentage) || 0, resets: Number(u.resets_at) || 0 } : null;
        } catch { /* a half-written file: keep the last reading */ }
      }
      // Codex says only when asked (its app server takes a second), so at most every two minutes.
      if (open.has("codex") && !(Date.now() - (this.codexAt ?? 0) < 120000)) {
        this.codexAt = Date.now();
        try {
          const r = await exec(`${mine}/codex-limits.sh`, [], { timeout: 25000 });
          const lim = JSON.parse(r.stdout.trim()).result?.rateLimits;
          // The 5-hour window when the plan has one, else its first (the free plan's 30 days).
          const w = [lim?.primary, lim?.secondary].find((x) => x?.windowDurationMins === 300) ?? lim?.primary;
          raw.codex = w ? { used: Number(w.usedPercent) || 0, resets: Number(w.resetsAt) || 0 } : null;
        } catch { /* Codex not signed in or slow: keep the last reading */ }
      }
      if (open.has("opencode")) {
        try {
          // OpenCode runs on free models with no limit: its fresh tokens (input, output, reasoning; not cache) over 5 hours.
          const since = Date.now() - 5 * 3600 * 1000;
          const r = await exec("sqlite3", ["-readonly", `${home()}/.local/share/opencode/opencode.db`,
            `select coalesce(sum(json_extract(data,'$.tokens.input')+json_extract(data,'$.tokens.output')+json_extract(data,'$.tokens.reasoning')),0) from session_message where type='assistant' and time_created > ${since};`],
            { timeout: 5000 });
          raw.opencode = r.code === 0 ? { tokens: Number(r.stdout.trim()) || 0 } : null;
        } catch { raw.opencode = null; }
      }
      if (piBridged) raw.pi = raw.claude;
      else if (open.has("pi")) {
        // Pi on an Anthropic login is billed per token as extra usage, not against the Claude plan: its tokens over 5 hours.
        try { const r = await exec(`${mine}/pi-tokens.sh`, [], { timeout: 10000 }); raw.pi = { tokens: Number(r.stdout.trim()) || 0 }; }
        catch { raw.pi = null; }
      }
      // Redraw only when what the rows show changes: the minute of the countdowns included.
      const sig = JSON.stringify([raw, [...open], Math.floor(Date.now() / 60000)]);
      if (sig === this.usageSig) return;
      this.raw = raw; this.usageSig = sig;
      // The footer grows a row per harness shown.
      const n = this.harnessesOpen().filter((h) => raw[h.key]).length;
      const px = Math.max(44, 16 + n * 16 + Math.max(0, n - 1) * 4);
      if (px !== this.footerPx) { this.footerPx = px; run("layout.resize", { id: "sidebar-footer", px }); }
      cx.notify();
    });
  }

  usageRow(t, h, d) {
    let left, right, a11y;
    if ("tokens" in d) {
      left = 100 - (d.tokens / TOKEN_SCALE) * 100;
      right = d.tokens >= 1e6 ? `${(d.tokens / 1e6).toFixed(1)}M` : d.tokens >= 1000 ? `${Math.round(d.tokens / 1000)}k` : `${d.tokens}`;
      a11y = `${h.name}: ${right} tokens in the last 5 hours`;
    } else {
      const now = Date.now() / 1000, live = d.resets > now;
      // Past its reset the window has started over, whatever the last reading said.
      left = live ? 100 - d.used : 100;
      const mins = live ? Math.round((d.resets - now) / 60) : 0;
      right = !live ? "reset" : mins >= 2880 ? `${Math.round(mins / 1440)}d` : mins >= 60 ? `${Math.floor(mins / 60)}h ${mins % 60}m` : `${mins}m`;
      a11y = `${h.name}: ${Math.round(left)}% left, ${live ? `resets in ${right}` : "window reset"}`;
    }
    left = Math.max(0, Math.min(100, left));
    // Fixed-width sides (no shrinking or growing past their width), so every bar starts and ends at the same place.
    const side = (text, end) => div().flex_none().w(end ? 48 : 36).min_w(end ? 48 : 36).max_w(end ? 48 : 36).overflow_hidden().whitespace_nowrap().text_size(11).text_color(t.muted).when(end, (el) => el.text_right()).child(text);
    return h_flex().id(`usage-${h.key}`).w_full().h(16).gap(8).items_center().accessibility_label(a11y)
      .child(side(`${Math.round(left)}%`, false))
      .child(div().flex_1().min_w(0).h(4).rounded_full().bg(t.border)
        .child(div().h_full().rounded_full().bg(left <= 10 ? t.blocked : h.color).w(`${left}%`).transition("width", { duration: 400, easing: "ease-out" })))
      .child(side(right, true));
  }

  usageBar(t) {
    const rows = this.harnessesOpen().filter((h) => this.raw?.[h.key]).map((h) => this.usageRow(t, h, this.raw[h.key]));
    return v_flex().flex_1().min_w(0).gap(4).justify_center().children(rows);
  }

  alignLights(cx) {
    if (shared("layout") !== "herdr-t3") return;
    const root = /** @type {any} */ (layout()), w = window(), zoom = Number(settings().zoom) || 1;
    if (w?.platform !== "macos" || w.fullscreen || root?.titlebar !== "none" || !root.traffic_lights || this.lightsWriting) return;
    // Once per zoom and layout value: an update that rewrites the layout is aligned again, a failure isn't retried.
    const seen = `${zoom}:${root.traffic_lights[1]}`;
    if (this.lightsSeen === seen) return;
    this.lightsSeen = seen;
    // Native buttons are unzoomed, centered 8px below y; the brand row's center is 20 logical px.
    const y = Math.round((12 + 20 * (zoom - 1)) * 1000) / 1000;
    if (root.traffic_lights[1] === y) return;
    this.lightsWriting = true;
    cx.spawn(async () => {
      try {
        const file = `${appHome()}/layouts/herdr-t3.json`, before = await readTextFile(file);
        if (before === null) throw new Error("Couldn't read the layout file.");
        const saved = JSON.parse(before);
        if (saved.titlebar !== "none" || !saved.traffic_lights || saved.traffic_lights[1] === y) return;
        saved.traffic_lights = [saved.traffic_lights[0], y];
        const after = before.replace(/("traffic_lights"\s*:\s*)\[[^\]]*\]/, (_match, key) => key + JSON.stringify(saved.traffic_lights));
        if (JSON.stringify(JSON.parse(after)) !== JSON.stringify(saved)) throw new Error("Couldn't locate the layout's window buttons.");
        await writeTextFile(file, after, before);
      } catch (e) {
        notify({ title: "Couldn't align the window buttons", body: String(e), level: "error" });
      } finally { this.lightsWriting = false; }
    });
  }

  render() {
    if (props()?.view === "settings") return settingsView(this);
    const t = theme();
    if (props()?.part === "panel") return this.panelHead(t);
    if (props()?.footer) {
      // As T3's footer: a row of 32px icon buttons, and at its end, once Herdr has downloaded an update, its restart.
      const ready = updates().app.ready;
      // T3's undo notice, the inbox's (t3-inbox.notice), in this row's free space so it covers nothing: "Settled," or
      // "Settled 2," then Undo, which the inbox does. It fades in and out over 200ms, Undo inert while it goes. One older than
      // its 5s and the fade is left from before a restart.
      const n = shared(KEY.notice);
      // Short of room the summary is cut, never Undo: GPUI's flex doesn't do T3's two wraps, which squeezed Undo to nothing.
      const notice = n && Date.now() - n.at < 6000 && h_flex().id(`undo-notice-${n.gen}`).flex_1().min_w(0).h(24).justify_end().gap(4).items_center()
        .text_size(11).text_color(t.dim).opacity(n.shown ? 1 : 0).transition("opacity", { duration: 200, easing: "ease-out" })
        .child(div().min_w(0).truncate().child(`${n.action}${n.count === 1 ? "" : ` ${n.count}`},`))
        // As T3's InlineButton: medium, foreground, underlined on hover.
        .child(h_flex().id("undo-notice-undo").flex_none().h(24).items_center().font_medium().text_color(t.foreground)
          .when(n.live && Date.now() - n.at < 5000, (el) => el.hover((s) => s.underline()).role("button").accessibility_label(`Undo: ${n.action} ${n.count} agent${n.count === 1 ? "" : "s"}`)
            .on_click(() => run("t3-tabs.undo")))
          .child("Undo")
          .when(n.live && Date.now() - n.at < 5000, (el) => stop(this, t, "undo-notice-undo", el, 4)));
      // T3's footer: 8 in and 4 above its row, whatever height the layout gives the block.
      return focusRoot(this, div().size_full().bg(t.chrome).px(12).py(8).child(h_flex().size_full().gap(4).items_center()
        .child(notice || this.usageBar(t))
        .when(Boolean(ready), el => el.child(tip(this, t, "app-update", `Update ${ready} downloaded. Click to restart`, stop(this, t, "app-update", div().id("app-update").h(32).px(12).flex_none().flex().items_center()
          .rounded_full().bg(t.accent + "26").text_size(12).text_color(t.accent).hover(s => s.bg(t.accent + "40")).on_hover(glow(this, "app-update"))
          .role("button").accessibility_label(`Restart into Herdr ${ready}`)
          .on_click(() => run("app.update")).child("Update"), 16))))));
    }
    // Room for the macOS window buttons (layout traffic_lights), a place to drag the window, and the
    // sidebar toggle at its right edge; while the sidebar is hidden, t3-tabs shows it after the buttons.
    const inbox = inboxShown(), w = window();
    // Herdr's mark and name where its own layout has them, past the macOS window buttons; a click goes Home, which has no
    // button of its own. Its colours are louder than anything else here, so it waits at 70% and its name is muted, both lit
    // on hover, with no background behind them. As T3's, no tooltip. The window buttons are screen points, unzoomed: the last ends at 68
    // (traffic_lights x 16, three 12s 8 apart), and the logo's tile shows 16pt from it, less the PNG's 2 of clear edge and
    // this button's 6 in. Short of room the name gives way whole, never cut to "Her…", and never the buttons.
    const zoom = settings().zoom || 1, left = w?.platform === "macos" && !w?.fullscreen ? (68 + 16 - 2) / zoom - 6 : 8, on = this.hot === "home"
      // Lit at Home too: its tab bar is empty and its panes may be anyone's, so this says where you are.
      || spaces().some((s) => s.active && s.id === shared(KEY.home));
    // What the name has past the left inset: less the 8 at the right, two 28px buttons, this button's 6 each side, the 20px logo and 8 gap.
    const named = !this.brandW || this.brandW - left - 8 - 56 - 12 - 20 - 8 >= (this.nameW || 0);
    return focusRoot(this, h_flex().id("brand").size_full().bg(t.chrome).pl(left).pr(8).items_center()
      .on_size_change((size, cx) => { this.brandW = size.width / zoom; cx.notify(); })
      .child(stop(this, t, "home", h_flex().id("home").h(28).min_w(0).px(6).gap(8).items_center().rounded(8)
        .text_size(14).font_medium().text_color(on ? t.foreground : t.muted).on_hover(glow(this, "home"))
        .role("button").accessibility_label("Home")
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        .on_click(() => run("t3-tabs.home"))
        .child(image("frame/welcome/herdr.png").size(20).flex_none().rounded(5).opacity(on ? 1 : 0.7))
        .when(named, el => el.child(div().id("home-name").flex_none().child("Herdr")
          .on_size_change((size, cx) => { this.nameW = size.width / zoom; cx.notify(); }))), 8))
      .child(div().flex_1())
      // T3's 28px title bar buttons, side by side instead of its 12 apart, so each stands over a button of the list's top row below.
      // The mode a click shows: a tray for the Inbox, rows with their marks for the lists.
      .child(tip(this, t, "sidebar-mode", inbox ? "Show lists" : "Show inbox", stop(this, t, "sidebar-mode", drawButton(t, "sidebar-mode", {
        size: "sm", icon: `mods/t3-chrome/icons/${inbox ? "layout-list" : "inbox"}.svg`, label: inbox ? "Show lists" : "Show inbox", hot: this.hot === "sidebar-mode" })
        .on_hover(glow(this, "sidebar-mode"))
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        .on_click(() => run("t3-tabs.sidebar")), radiusOf("sm")), { action: "t3-tabs.sidebar", below: true }))
      .child(tip(this, t, "sidebar-toggle", "Hide sidebar", stop(this, t, "sidebar-toggle", drawButton(t, "sidebar-toggle", {
        size: "sm", icon: "mods/t3-chrome/icons/panel-left.svg", label: "Hide sidebar", hot: this.hot === "sidebar-toggle" })
        .on_hover(glow(this, "sidebar-toggle"))
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        // It goes with the sidebar, before the pointer can report leaving it.
        .on_click(() => { this.hot = null; run("layout.toggle", { id: "sidebar" }); }), radiusOf("sm")), { action: "layout.toggle:sidebar", below: true })));
  }

  // The space panel's top: its pages as T3's panel tabs (24px, 12px words), then widen and close as 24px icon buttons.
  // The rest of the row drags the window, as the tab bar does.
  panelHead(t) {
    const s = panelState(), space = spaces().find(p => p.active);
    // Review's run for this space, marked as a tab's agent is: what was news in a pane's card before (docs/adr/0011).
    const word = space && shared("review.status")?.[space.id];
    const mark = word === "working" ? svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900)
      : word === "blocked" ? div().size(14).flex_none().rounded(4).bg(t.blocked + "26").text_size(11).font_bold().text_color(t.blocked).flex().items_center().justify_center().child("!")
      : word === "done" ? div().size(6).flex_none().rounded_full().bg(t.done) : null;
    const own = (el) => el.on_mouse_down("left", (_e, cx) => cx.stop_propagation());
    const page = (id) => {
      const [label, icon, colored] = PAGES[id] ?? [id, "folder-tree"], on = s.page === id, key = `page-${id}`;
      return stop(this, t, key, own(h_flex().id(key).h(24).pl(6).pr(8).gap(6).flex_none().items_center().rounded(6).text_size(12)
        .bg(on ? t.selected : t.chrome).text_color(on || this.hot === key ? t.foreground : t.muted)
        .when(!on, el => el.hover(st => st.bg(t.hover))).on_hover(glow(this, key))
        .role("tab").accessibility_label(label)
        .on_click(() => showPage(id))
        // A colored mark waits at 70% until its tab is shown or hovered, as the brand bar's Herdr mark.
        .child(colored ? image(`mods/t3-chrome/icons/${icon}.svg`).size(14).flex_none().opacity(on || this.hot === key ? 1 : 0.7)
          : svg(`mods/t3-chrome/icons/${icon}.svg`).size(14).flex_none())
        .child(label)
        .when(id === "review" && mark != null, el => el.child(mark))), 6);
    };
    const button = (id, icon, label, action, key) => tip(this, t, id, label, stop(this, t, id, own(drawButton(t, id, {
      icon: `mods/t3-chrome/icons/${icon}.svg`, label, hot: this.hot === id })
      .on_hover(glow(this, id))
      .on_click((_e, cx) => { this.hot = null; action(); cx.notify(); })), radiusOf("xs")), { action: key, below: true });
    return focusRoot(this, h_flex().id("panel-head").size_full().bg(t.chrome).gap(4).items_center()
      .children(s.pages.map(page))
      .child(div().flex_1())
      .child(button("panel-wide", s.wide ? "minimize-2" : "maximize-2", s.wide ? "Restore panel" : "Expand panel", toggleWide))
      .child(button("panel-close", "x", "Close panel", hidePanel, "t3-tabs.panel")));
  }
}
