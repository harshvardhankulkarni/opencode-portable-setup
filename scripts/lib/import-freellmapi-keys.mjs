#!/usr/bin/env node
// import-freellmapi-keys.mjs
// Helper for freellmapi-keys.json (21 provider keys) — validate, redact, export to env.
// Never prints raw keys unless --show is passed. Designed for new-machine setup.
//
// Usage:
//   node scripts/lib/import-freellmapi-keys.mjs --check            # validate candidates, print count + platforms
//   node scripts/lib/import-freellmapi-keys.mjs --check --verbose  # + which file was used
//   node scripts/lib/import-freellmapi-keys.mjs --print-env         # dry-run: print export lines (still masked by default)
//   node scripts/lib/import-freellmapi-keys.mjs --print-env --show  # print real keys (use only in secure shell)
//   node scripts/lib/import-freellmapi-keys.mjs --export-env >> .env  # masked keys only — replace manually
//   node scripts/lib/import-freellmapi-keys.mjs --export-env --show >> .env  # appends real keys (review .gitignore!)
//   node scripts/lib/import-freellmapi-keys.mjs --redact freellmapi/keys.json  # prints redacted JSON to stdout (> keys.json.example)
//   node scripts/lib/import-freellmapi-keys.mjs --redact freellmapi-keys.json > freellmapi/keys.json.example
//
// Exit 0 on success, 1 if no file found or JSON invalid, 2 if keys look placeholder/incomplete.

import fs from "node:fs";
import path from "node:path";
import os from "node:os";

const HOME = os.homedir();
const REPO = path.resolve(import.meta.dirname ? path.join(import.meta.dirname, "../..") : "C:/Users/PilzIndia/opencode-portable-setup");

const CANDIDATES = [
  "freellmapi-keys.json",
  "freellmapi/keys.json",
  "freellmapi-keys.json.example", // for --redact source
  "freellmapi/keys.json.example",
  path.join(HOME, "freellmapi-keys.json"),
  path.join(HOME, "freellmapi/keys.json"),
  path.join(HOME, "Desktop/freellmapi-keys.json"),
  path.join(HOME, ".freellmapi/keys.json"),
  "./freellmapi-keys.json",
  "./freellmapi/keys.json",
];

function findFile(explicit) {
  if (explicit && fs.existsSync(explicit)) return explicit;
  for (const p of CANDIDATES) {
    // expand HOME already; for relative, try REPO + HOME
    const tryPaths = [p, path.join(REPO, p), path.isAbsolute(p) ? p : path.join(REPO, p)];
    for (const tp of tryPaths) {
      if (fs.existsSync(tp)) return tp;
    }
  }
  return null;
}

function parseArgs() {
  const a = process.argv.slice(2);
  const o = { show: false, verbose: false, check: false, printEnv: false, exportEnv: false, redact: null, file: null, help: false };
  for (let i = 0; i < a.length; i++) {
    const arg = a[i];
    if (arg === "--help" || arg === "-h") o.help = true;
    else if (arg === "--show") o.show = true;
    else if (arg === "--verbose" || arg === "-v") o.verbose = true;
    else if (arg === "--check") o.check = true;
    else if (arg === "--print-env") o.printEnv = true;
    else if (arg === "--export-env") o.exportEnv = true;
    else if (arg === "--redact") o.redact = a[++i] || null;
    else if (!arg.startsWith("--") && !o.file) o.file = arg;
  }
  if (!o.check && !o.printEnv && !o.exportEnv && !o.redact && !o.help) o.check = true; // default
  return o;
}

function loadKeys(file) {
  const raw = fs.readFileSync(file, "utf8");
  const data = JSON.parse(raw);
  const keys = Array.isArray(data) ? data : (data.keys || []);
  return { raw, data, keys };
}

function platformEnvName(platform) {
  // Best-effort mapping to env var per provider (for --export-env)
  // These are conventions; FreeLLMAPI itself reads freellmapi-keys.json natively, so env export is optional.
  const map = {
    agnes: "AGNES_API_KEY",
    aion: "AION_API_KEY",
    bai: "BAI_API_KEY",
    cerebras: "CEREBRAS_API_KEY",
    cloudflare: "CLOUDFLARE_API_KEY",
    github: "GITHUB_MODELS_API_KEY",
    google: "GOOGLE_API_KEY",
    groq: "GROQ_API_KEY",
    huggingface: "HUGGINGFACE_API_KEY",
    llm7: "LLM7_API_KEY",
    nvidia: "NVIDIA_API_KEY",
    ollama: "OLLAMA_API_KEY",
    opencode: "OPENCODE_API_KEY",
    openrouter: "OPENROUTER_API_KEY",
    orcarouter: "ORCAROUTER_API_KEY",
    pollinations: "POLLINATIONS_API_KEY",
    reka: "REKA_API_KEY",
    requesty: "REQUESTY_API_KEY",
    routeway: "ROUTEWAY_API_KEY",
    siliconflow: "SILICONFLOW_API_KEY",
    zhipu: "ZHIPU_API_KEY",
  };
  return map[platform] || `${platform.toUpperCase()}_API_KEY`;
}

function redactData(data) {
  // Replace any string longer than 12 chars with ${REDACTED}, keep platform/label
  const clone = JSON.parse(JSON.stringify(data));
  const keys = Array.isArray(clone) ? clone : (clone.keys || []);
  for (const k of keys) {
    if (typeof k.key === "string" && k.key.length > 0) {
      // Preserve prefix length hint for format, but hide value
      const prefix = k.key.slice(0, Math.min(6, k.key.length));
      // If custom redaction wanted per platform, keep platform prefix style
      if (k.key.includes(":")) {
        // cloudflare  xxx:cfat_xxx
        k.key = "${REDACTED}:cfat_${REDACTED}";
      } else {
        k.key = k.key.includes("sk-or") ? `sk-or-v1-\${REDACTED}` : `${prefix}\${REDACTED}`;
        // Simplify: if original had ${REDACTED} style, just use that
        if (k.platform === "orcarouter") k.key = "sk-orca-${REDACTED}";
        else if (k.platform === "requesty") k.key = "rqsty-sk-${REDACTED}";
        else if (k.platform === "llm7") k.key = "${REDACTED}";
        else if (k.key.length > 20) k.key = `sk-\${REDACTED}`;
      }
    }
  }
  // Also redact if top-level is array
  if (Array.isArray(clone)) return clone;
  return clone;
}

function mask(v, show) {
  if (show) return v;
  if (typeof v !== "string") return v;
  if (v.length <= 12) return "*".repeat(v.length);
  return v.slice(0, 8) + "…" + "*".repeat(Math.max(8, v.length - 16)) + v.slice(-4);
}

function main() {
  const opts = parseArgs();
  if (opts.help) {
    console.log(`import-freellmapi-keys.mjs

Checks/exports freellmapi-keys.json (21 provider keys).
Real file is NEVER committed — only freellmapi/keys.json.example (redacted) is in repo.

Usage:
  node scripts/lib/import-freellmapi-keys.mjs --check [--verbose] [--show] [path/to/freellmapi-keys.json]
  node scripts/lib/import-freellmapi-keys.mjs --print-env [--show]
  node scripts/lib/import-freellmapi-keys.mjs --export-env [--show] >> .env
  node scripts/lib/import-freellmapi-keys.mjs --redact [path/to/real.json] > freellmapi/keys.json.example

Candidates checked (in order): ${CANDIDATES.join(", ")}

Exit codes:
  0  found + valid
  1  not found or invalid JSON
  2  placeholder/incomplete (e.g. <10 keys or contains your-*-here / \${REDACTED})
`);
    process.exit(0);
  }

  if (opts.redact !== null) {
    const src = opts.redact || opts.file;
    const file = findFile(src);
    if (!file) {
      console.error(`[redact] file not found: ${src || "(auto)"} — checked: ${CANDIDATES.join(", ")}`);
      process.exit(1);
    }
    const { data } = loadKeys(file);
    const redacted = redactData(data);
    console.log(JSON.stringify(redacted, null, 2));
    process.exit(0);
  }

  const file = findFile(opts.file);
  if (!file) {
    console.error(`[freellmapi-keys] not found. Checked:`);
    for (const c of CANDIDATES) console.error(`  - ${c} ${fs.existsSync(c) ? "(exists but not valid JSON?)" : "(missing)"}`);
    console.error(`\nPlace your REAL freellmapi-keys.json at one of:`);
    console.error(`  ./freellmapi-keys.json  or  ./freellmapi/keys.json`);
    console.error(`Get it from source machine: Desktop/freellmapi-keys.json or ~/.freellmapi/keys.json`);
    console.error(`Repo template: freellmapi/keys.json.example (redacted)`);
    process.exit(1);
  }

  let keys, data;
  try {
    ({ keys, data } = loadKeys(file));
  } catch (e) {
    console.error(`[freellmapi-keys] invalid JSON in ${file}: ${e.message}`);
    process.exit(1);
  }

  const platforms = keys.map(k => k.platform).filter(Boolean);
  const keyCount = keys.length;
  const uniq = new Set(platforms);

  // Heuristics: placeholder / incomplete
  const placeholderKeys = keys.filter(k => {
    const v = k.key || "";
    return /your-.*-here|\$\{REDACTED\}|xxxx|placeholder/i.test(v) || v.length < 12;
  });

  if (opts.verbose) console.log(`[freellmapi-keys] file: ${file}`);

  if (opts.check || (!opts.printEnv && !opts.exportEnv)) {
    console.log(`[freellmapi-keys] ${keyCount} keys from ${file}`);
    console.log(`  platforms: ${platforms.join(", ")}`);
    if (uniq.size !== keyCount) console.warn(`  warn: duplicate platforms (uniq ${uniq.size} vs ${keyCount})`);
    if (keyCount < 10) console.warn(`  warn: only ${keyCount} keys — expected 21 (upload your full bundle)`);
    if (placeholderKeys.length > 0) {
      console.warn(`  warn: ${placeholderKeys.length} placeholder keys: ${placeholderKeys.map(k => k.platform).join(", ")}`);
    }
    if (opts.verbose) {
      for (const k of keys) {
        console.log(`    - ${k.platform}: ${mask(k.key, opts.show)} ${k.label ? `(${k.label})` : ""}`);
      }
    }
    if (placeholderKeys.length > 0) process.exit(2);
    if (keyCount < 5) process.exit(2);
    process.exit(0);
  }

  if (opts.printEnv || opts.exportEnv) {
    const lines = [];
    if (opts.exportEnv) {
      lines.push("# Added by import-freellmapi-keys.mjs from " + file + " on " + new Date().toISOString());
      lines.push("# FreeLLMAPI per-provider keys (optional — FreeLLMAPI primarily reads freellmapi-keys.json directly)");
    }
    for (const k of keys) {
      const envName = platformEnvName(k.platform);
      const val = k.key || "";
      if (opts.exportEnv) {
        lines.push(`${envName}=${opts.show ? val : mask(val, false)}`);
      } else {
        // --print-env is dry-run: same but to stdout, not intended to >> .env blindly
        lines.push(`${envName}=${opts.show ? val : mask(val, false)}`);
      }
    }
    // Also emit the two gateway auth vars as hints (not from keys.json, from .env)
    if (opts.verbose || opts.exportEnv) {
      lines.push("# Gateway auth (set these in .env too):");
      lines.push("# FREELLMAPI_API_KEY=your-freellmapi-key-here");
      lines.push("# ANTHROPIC_AUTH_TOKEN=your-anthropic-token-here  # or freellmapi-...");
    }
    console.log(lines.join("\n"));
    process.exit(0);
  }
}

main();
