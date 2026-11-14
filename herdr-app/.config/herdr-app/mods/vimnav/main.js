// vimnav: vim-tmux-navigator for Herdr.
// keys.json binds alt-h/j/k/l to "vimnav.left|down|up|right". When the focused
// pane runs (n)vim, the chord is passed into it (nvim moves its split and, at
// the edge, calls `herdr-app do pane.go`); otherwise Herdr moves pane focus.
// It has to be shown somewhere to get commands: layouts/mine.json gives it a
// 1px block beside the tab bar.
import { View, div } from "gpui-kit";
import { nextCommand, panes, run, hc } from "herdr";

const KEYS = { left: "alt+h", down: "alt+j", up: "alt+k", right: "alt+l" };
const VIM = /^(g?view|n?vim?x?)(diff)?$/i;

function isVim(pane) {
  const name = pane.program?.key ?? "";
  return VIM.test(name) || /\bn?vim\b/i.test(pane.program?.name ?? "");
}

export default class VimNav extends View {
  init(_props, cx) {
    cx.spawn(async (cx) => {
      for (;;) {
        const dir = await nextCommand();
        if (!KEYS[dir]) continue;
        const p = panes().find((p) => p.focused);
        if (p?.terminal && isVim(p)) {
          await hc(["keys", p.terminal, KEYS[dir]]);
        } else {
          run("pane.go", { direction: dir });
        }
      }
    });
  }

  render(_cx) {
    return div().size_full();
  }
}
