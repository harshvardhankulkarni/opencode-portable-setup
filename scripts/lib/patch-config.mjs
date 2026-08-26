#!/usr/bin/env node
/**
 * patch-config.mjs
 * Rewrites Windows-hardcoded paths in opencode.json -> portable $HOME paths.
 * Usage:
 *   node scripts/lib/patch-config.mjs --src config/opencode.json --dst /tmp/opencode.json [--home /home/user] [--os linux|win32|darwin]
 * If --dst omitted, patches in place.
 * If --home omitted, uses os.homedir().
 * If --os omitted, uses os.platform().
 */
import fs from "node:fs";
import path from "node:path";
import os from "node:os";

function parseArgs() {
  const a = process.argv.slice(2);
  const out = {};
  for (let i = 0; i < a.length; i++) {
    if (a[i].startsWith("--")) {
      const k = a[i].replace(/^--/, "");
      const v = a[i + 1] && !a[i + 1].startsWith("--") ? a[++i] : true;
      out[k] = v;
    }
  }
  return out;
}

const args = parseArgs();
const src = args.src || args.s || "config/opencode.json";
const dst = args.dst || args.d || src;
const homeRaw = args.home || os.homedir();
const platform = args.os || os.platform(); // win32 | linux | darwin

const home = homeRaw.replace(/\\/g, "/");
const isWin = platform === "win32";

let raw = fs.readFileSync(src, "utf8");
let data;
try {
  data = JSON.parse(raw);
} catch (e) {
  console.error(`[patch-config] Failed to parse JSON: ${src}: ${e.message}`);
  process.exit(1);
}

// Normalize a Windows path to portable
function winToPortable(p) {
  if (!p || typeof p !== "string") return p;
  // Known prefixes to replace
  const winPilz = "C:/Users/PilzIndia";
  const winPilzBs = "C:\\Users\\PilzIndia";
  if (p === winPilz || p === winPilzBs) {
    // filesystem allow dir — replace with $HOME or home
    return home;
  }
  if (p.startsWith(winPilz + "/")) {
    return p.replace(winPilz + "/", home + "/");
  }
  if (p.startsWith(winPilzBs + "\\")) {
    return p.replace(winPilzBs + "\\", home + "/").replace(/\\/g, "/");
  }
  // Local bin patterns
  if (p.includes(".local/bin/codebase-memory-mcp")) {
    if (isWin) return `${home}/.local/bin/codebase-memory-mcp.exe`.replace(/\/\//g, "/");
    return `${home}/.local/bin/codebase-memory-mcp`;
  }
  if (p.includes("codebase-memory-mcp.exe")) {
    if (isWin) return `${home}/.local/bin/codebase-memory-mcp.exe`;
    return `${home}/.local/bin/codebase-memory-mcp`;
  }
  if (p.includes("codebase-memory-mcp")) {
    return isWin ? `${home}/.local/bin/codebase-memory-mcp.exe` : `${home}/.local/bin/codebase-memory-mcp`;
  }
  if (p.includes("officecli.exe")) {
    return isWin ? `${home}/bin/officecli.exe` : "officecli";
  }
  if (p.includes("officecli")) {
    return isWin ? `${home}/bin/officecli.exe` : "officecli";
  }
  return p;
}

let patched = 0;

// Patch mcp
if (data.mcp && typeof data.mcp === "object") {
  for (const [name, cfg] of Object.entries(data.mcp)) {
    if (!cfg || typeof cfg !== "object") continue;
    // command array
    if (Array.isArray(cfg.command)) {
      const next = cfg.command.map((c) => {
        const np = winToPortable(c);
        if (np !== c) patched++;
        return np;
      });
      cfg.command = next;
      // heuristic: if filesystem command third arg is a Windows user dir, patch to home
      if (name === "filesystem" && next.length >= 3) {
        // allow dir
        if (next[2].includes("PilzIndia") || next[2].includes("C:/")) {
          cfg.command[2] = home;
          patched++;
        }
        // also ensure arg is not empty
        if (!cfg.command[2]) cfg.command[2] = home;
      }
      if (name === "playwright" || name === "officecli") {
        // ensure npx prefix where needed stays
      }
    }
    // legacy: some configs store single string
    if (typeof cfg.command === "string") {
      const np = winToPortable(cfg.command);
      if (np !== cfg.command) {
        cfg.command = np;
        patched++;
      }
    }
  }
}

// Patch provider baseURLs? Keep as-is (localhost) - no path to patch

// Generic string scan for any remaining PilzIndia
let jsonStr = JSON.stringify(data, null, 2);
const before = jsonStr;
if (jsonStr.includes("PilzIndia") || jsonStr.includes("C:/Users") || jsonStr.includes("C:\\Users")) {
  jsonStr = jsonStr.replaceAll("C:/Users/PilzIndia", home);
  jsonStr = jsonStr.replaceAll("C:\\\\Users\\\\PilzIndia", home.replaceAll("/", "\\\\"));
  jsonStr = jsonStr.replaceAll("C:\\Users\\PilzIndia", home);
  // Count
  if (jsonStr !== before) {
    patched++;
    data = JSON.parse(jsonStr);
  } else {
    // fallback regex
    jsonStr = before.replace(/C:[\\/]+Users[\\/]+PilzIndia/g, home);
    if (jsonStr !== before) {
      data = JSON.parse(jsonStr);
      patched++;
    }
  }
}

// Ensure filesystem MCP has sane allowed dir
if (data.mcp?.filesystem?.command) {
  const cmd = data.mcp.filesystem.command;
  if (Array.isArray(cmd) && cmd.length === 3) {
    // If third arg is still Windows or missing, set to home
    if (!fs.existsSync(cmd[2]) && !cmd[2].startsWith(home)) {
      // only warn, don\'t override if user has custom; keep home default
    }
  }
}

// Write
const outStr = JSON.stringify(data, null, 2) + "\n";
fs.mkdirSync(path.dirname(dst), { recursive: true });
fs.writeFileSync(dst, outStr, "utf8");

console.log(`[patch-config] ${src} -> ${dst} | platform=${platform} home=${home} | patches=${patched}`);
if (patched === 0) console.log(`[patch-config] No Windows paths found — already portable.`);
else console.log(`[patch-config] Patched ${patched} entry(ies). Review diff if needed.`);
