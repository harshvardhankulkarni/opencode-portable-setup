#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { execSync } from "node:child_process";
const HOME = process.env.HOME || process.env.USERPROFILE || "C:/Users/PilzIndia";
const REPO = "C:/Users/PilzIndia/opencode-portable-setup";
const SRC_CLAUDE = path.join(HOME, ".claude");
const SRC_CODEX = path.join(HOME, ".codex");
const SRC_OMNI = path.join(HOME, ".omniroute");
const SRC_QWEN = path.join(HOME, ".qwen");
const SRC_GEMINI = path.join(HOME, ".gemini");
const SRC_AGENTS = path.join(HOME, ".agents");
function ensure(p){ fs.mkdirSync(p,{recursive:true});}
function sanitizeToken(v){ if(typeof v==="string" && v.length>0) return "${"+v+"}".replace(v,"${TOKEN}") ; return v; }
function copyDirSync(src,dst,opts={}){
  if(!fs.existsSync(src)) { console.log(`skip missing ${src}`); return 0;}
  ensure(dst);
  let count=0;
  for(const e of fs.readdirSync(src,{withFileTypes:true})){
    if(e.name===".git" || e.name==="node_modules" || e.name===".next" || e.name==="__pycache__") continue;
    const s=path.join(src,e.name);
    const d=path.join(dst,e.name);
    try{
      if(e.isSymbolicLink()){
        try{
          const target=fs.readlinkSync(s);
          let realTarget;
          if(path.isAbsolute(target)) realTarget=target;
          else realTarget=path.resolve(path.dirname(s),target);
          if(fs.existsSync(realTarget)){
            const stat=fs.statSync(realTarget);
            if(stat.isDirectory()) { copyDirSync(realTarget,d); count++; }
            else { ensure(path.dirname(d)); try{fs.copyFileSync(realTarget,d); count++;}catch(err){console.log(`copy fail ${realTarget} -> ${d}: ${err.code}`)} }
          } else {
            try{ fs.symlinkSync(target,d);}catch{}
          }
        }catch(err){ console.log(`symlink fail ${s}: ${err.message}`)}
      } else if(e.isDirectory()){
        count+=copyDirSync(s,d,opts);
      } else if(e.isFile()){
        ensure(path.dirname(d));
        try{ fs.copyFileSync(s,d); count++; }catch(err){ console.log(`copy fail ${s} -> ${d}: ${err.code} ${err.message}`); }
      }
    }catch(err){ console.log(`entry fail ${s}: ${err.message}`)}
  }
  return count;
}
function sanitizeJsonFile(src,dst,transform){
  if(!fs.existsSync(src)) return;
  ensure(path.dirname(dst));
  let data=JSON.parse(fs.readFileSync(src,"utf8"));
  if(transform) data=transform(data);
  fs.writeFileSync(dst,JSON.stringify(data,null,2));
}
// 1. Claude settings sanitized
console.log("1. Claude settings...");
if(fs.existsSync(path.join(SRC_CLAUDE,"settings.json"))){
  sanitizeJsonFile(path.join(SRC_CLAUDE,"settings.json"), path.join(REPO,"claude/settings.json"), (data)=>{
    const d=JSON.parse(JSON.stringify(data));
    if(d.env){
      for(const k of Object.keys(d.env)){
        const v=d.env[k];
        if(typeof v==="string" && (k.includes("TOKEN")||k.includes("KEY")||k.includes("AUTH")||k.includes("SECRET"))){
          d.env[k]="${"+k+"}";
        }
      }
    }
    return d;
  });
  fs.copyFileSync(path.join(REPO,"claude/settings.json"), path.join(REPO,"claude/settings.json.example"));
  console.log(" -> claude/settings.json");
}
// .mcp.json
if(fs.existsSync(path.join(SRC_CLAUDE,".mcp.json"))){
  let raw=fs.readFileSync(path.join(SRC_CLAUDE,".mcp.json"),"utf8");
  raw=raw.replace(/fc-[a-z0-9]+/g,"${FIRECRAWL_API_KEY}");
  raw=raw.replace(/C:\/Users\/PilzIndia/g, "~");
  raw=raw.replace(/C:\\\\Users\\\\PilzIndia/g, "~");
  raw=raw.replace(/C:\/Users\/PilzIndia/g, "${HOME}");
  let data=JSON.parse(raw);
  for(const k of Object.keys(data.mcpServers||{})){
    const s=data.mcpServers[k];
    if(s && s.command && typeof s.command==="string" && s.command.includes("PilzIndia")){
      s.command=s.command.replace("C:/Users/PilzIndia","~").replace("C:\\Users\\PilzIndia","~");
    }
  }
  ensure(path.join(REPO,"claude"));
  fs.writeFileSync(path.join(REPO,"claude/mcp.json"), JSON.stringify(data,null,2));
  fs.writeFileSync(path.join(REPO,"claude/mcp.json.example"), JSON.stringify(data,null,2));
  console.log(" -> claude/mcp.json");
}
if(fs.existsSync(path.join(SRC_CLAUDE,"CLAUDE.md"))){
  ensure(path.join(REPO,"claude"));
  fs.copyFileSync(path.join(SRC_CLAUDE,"CLAUDE.md"), path.join(REPO,"claude/CLAUDE.md"));
  console.log(" -> claude/CLAUDE.md");
}
if(fs.existsSync(path.join(HOME,".mcp.json"))){
  let raw=fs.readFileSync(path.join(HOME,".mcp.json"),"utf8");
  let data=JSON.parse(raw);
  ensure(path.join(REPO,"claude"));
  fs.writeFileSync(path.join(REPO,"claude/home-mcp.json.example"), JSON.stringify(data,null,2));
  console.log(" -> claude/home-mcp.json.example");
}
if(fs.existsSync(path.join(SRC_CLAUDE,"settings.local.json"))){
  sanitizeJsonFile(path.join(SRC_CLAUDE,"settings.local.json"), path.join(REPO,"claude/settings.local.json.example"));
  console.log(" -> claude/settings.local.json.example");
}
// 2. Claude agents/skills/commands/hooks - full copy dereferenced where needed
console.log("2. Claude agents...");
let n=copyDirSync(path.join(SRC_CLAUDE,"agents"), path.join(REPO,"claude/agents"));
console.log(` -> agents: ${n} files, ${fs.readdirSync(path.join(REPO,"claude/agents")).length} top entries`);
console.log("3. Claude skills...");
n=copyDirSync(path.join(SRC_CLAUDE,"skills"), path.join(REPO,"claude/skills"));
console.log(` -> skills: ${n} files`);
console.log("4. Claude commands...");
n=copyDirSync(path.join(SRC_CLAUDE,"commands"), path.join(REPO,"claude/commands"));
console.log(` -> commands: ${n} files`);
console.log("5. Claude hooks...");
n=copyDirSync(path.join(SRC_CLAUDE,"hooks"), path.join(REPO,"claude/hooks"));
console.log(` -> hooks: ${n} files`);
console.log("6. Claude plugins inventory...");
ensure(path.join(REPO,"claude/plugins"));
if(fs.existsSync(path.join(SRC_CLAUDE,"plugins"))){
  // dont copy full plugins (large), just inventory
  try{
    const installed=path.join(SRC_CLAUDE,"plugins/installed_plugins.json");
    if(fs.existsSync(installed)){
      fs.copyFileSync(installed, path.join(REPO,"claude/plugins/installed_plugins.json"));
      console.log(" -> plugins/installed_plugins.json");
    }
  }catch(e){ console.log(e.message)}
  try{
    const catalog=path.join(SRC_CLAUDE,"plugins/../plugin-catalog-cache.json");
  }catch{}
  // copy known_marketplaces
  const km=path.join(SRC_CLAUDE,"plugins/../known_marketplaces.json");
  // Actually at .claude/plugins/known_marketplaces.json? check src
}
if(fs.existsSync(path.join(SRC_CLAUDE,"plugins/known_marketplaces.json"))){
  fs.copyFileSync(path.join(SRC_CLAUDE,"plugins/known_marketplaces.json"), path.join(REPO,"claude/plugins/known_marketplaces.json"));
}
if(fs.existsSync(path.join(SRC_CLAUDE,"plugins/installed_plugins.json"))){
  // already
}
if(fs.existsSync(path.join(SRC_CLAUDE,"plugins/data"))){
  // skip large data
}
// also capture marketplace via settings
try{
  const settings=JSON.parse(fs.readFileSync(path.join(REPO,"claude/settings.json"),"utf8"));
  ensure(path.join(REPO,"claude/plugins"));
  fs.writeFileSync(path.join(REPO,"claude/plugins/enabledPlugins.json"), JSON.stringify(settings.enabledPlugins||{},null,2));
  fs.writeFileSync(path.join(REPO,"claude/plugins/extraKnownMarketplaces.json"), JSON.stringify(settings.extraKnownMarketplaces||{},null,2));
  console.log(" -> plugins/enabledPlugins.json");
}catch{}
// 7. Codex
console.log("7. Codex...");
ensure(path.join(REPO,"codex"));
if(fs.existsSync(path.join(SRC_CODEX,"config.toml"))){
  let raw=fs.readFileSync(path.join(SRC_CODEX,"config.toml"),"utf8");
  // sanitize firecrawl key inside if any, and windows paths
  raw=raw.replace(/fc-[a-z0-9]+/g,"${FIRECRAWL_API_KEY}");
  raw=raw.replace(/C:\/Users\/PilzIndia/g,"~");
  raw=raw.replace(/C:\\Users\\PilzIndia/g,"~");
  fs.writeFileSync(path.join(REPO,"codex/config.toml"), raw);
  fs.writeFileSync(path.join(REPO,"codex/config.toml.example"), raw);
  console.log(" -> codex/config.toml");
}
if(fs.existsSync(path.join(SRC_CODEX,"auth.json"))){
  let data=JSON.parse(fs.readFileSync(path.join(SRC_CODEX,"auth.json"),"utf8"));
  function redact(o){ for(const k in o){ if(typeof o[k]==="string" && (k.toLowerCase().includes("token")||k.toLowerCase().includes("key")||k.toLowerCase().includes("auth"))){ o[k]="${"+k.toUpperCase()+"}"; } else if(typeof o[k]==="object"&&o[k]&&!Array.isArray(o[k])) redact(o[k]); } }
  redact(data);
  ensure(path.join(REPO,"codex"));
  fs.writeFileSync(path.join(REPO,"codex/auth.json.example"), JSON.stringify(data,null,2));
  console.log(" -> codex/auth.json.example");
}
if(fs.existsSync(path.join(SRC_CODEX,"AGENTS.md"))){
  fs.copyFileSync(path.join(SRC_CODEX,"AGENTS.md"), path.join(REPO,"codex/AGENTS.md"));
}
if(fs.existsSync(path.join(SRC_CODEX,"skills"))){
  n=copyDirSync(path.join(SRC_CODEX,"skills"), path.join(REPO,"codex/skills"));
  console.log(` -> codex/skills: ${n}`);
}
// 8. OmniRoute
console.log("8. OmniRoute...");
ensure(path.join(REPO,"omniroute"));
if(fs.existsSync(path.join(SRC_OMNI,".env"))){
  let raw=fs.readFileSync(path.join(SRC_OMNI,".env"),"utf8");
  raw=raw.replace(/STORAGE_ENCRYPTION_KEY=.*/,"STORAGE_ENCRYPTION_KEY=${STORAGE_ENCRYPTION_KEY} # generate: openssl rand -hex 32");
  raw="# OmniRoute .env — sanitized example — copy to ~/.omniroute/.env and fill\n# Original generated via omniroute bootstrap\n"+raw;
  fs.writeFileSync(path.join(REPO,"omniroute/.env.example"), raw);
  console.log(" -> omniroute/.env.example");
}
if(fs.existsSync("C:/Users/PilzIndia/AppData/Roaming/npm/node_modules/omniroute/.env.example")){
  fs.copyFileSync("C:/Users/PilzIndia/AppData/Roaming/npm/node_modules/omniroute/.env.example", path.join(REPO,"omniroute/upstream-.env.example"));
  console.log(" -> omniroute/upstream-.env.example");
}
// copy omniroute call_logs inventory? just list
try{
  const files=fs.readdirSync(SRC_OMNI).filter(f=>fs.statSync(path.join(SRC_OMNI,f)).isDirectory());
  fs.writeFileSync(path.join(REPO,"omniroute/source-layout.txt"), files.join("\n"));
}catch{}
// 9. FreeLLMAPI
console.log("9. FreeLLMAPI...");
// already have README template, ensure it exists
// Copy desktop keys if exist? but sanitize - just inventory, dont copy secrets
if(fs.existsSync("C:/Users/PilzIndia/Desktop/freellmapi-keys.json")){
  try{
    ensure(path.join(REPO,"freellmapi"));
    let data=fs.readFileSync("C:/Users/PilzIndia/Desktop/freellmapi-keys.json","utf8");
    let j;
    try{ j=JSON.parse(data); }catch{ j=null; }
    if(j){
      let s=JSON.stringify(j).replace(/[a-z0-9]{20,}/gi,"${REDACTED}");
      fs.writeFileSync(path.join(REPO,"freellmapi/keys.json.example"), s);
      console.log(" -> freellmapi/keys.json.example (redacted)");
    } else {
      fs.writeFileSync(path.join(REPO,"freellmapi/keys.json.example"), data.replace(/[a-z0-9]{20,}/gi,"${REDACTED}"));
    }
  }catch(e){ console.log(`freellmapi json skip: ${e.message}`)}
} else {
  console.log(" -> freellmapi/keys.json not found (skip)");
}
if(fs.existsSync("C:/Users/PilzIndia/Desktop/freellmapi-keys.csv")){
  try{
    ensure(path.join(REPO,"freellmapi"));
    fs.copyFileSync("C:/Users/PilzIndia/Desktop/freellmapi-keys.csv", path.join(REPO,"freellmapi/keys.csv.example"));
    let raw=fs.readFileSync(path.join(REPO,"freellmapi/keys.csv.example"),"utf8");
    raw=raw.replace(/[a-z0-9\-]{20,}/gi,"${REDACTED}");
    fs.writeFileSync(path.join(REPO,"freellmapi/keys.csv.example"), raw);
    console.log(" -> freellmapi/keys.csv.example (redacted)");
  }catch(e){ console.log(`freellmapi csv skip: ${e.message}`)}
} else {
  console.log(" -> freellmapi/keys.csv not found on Desktop (skip)");
}
// freellmapi npx cache inventory
try{
  const npxPath="C:/Users/PilzIndia/AppData/Local/npm-cache/_npx/e995436d190f44dd/node_modules/freellmapi/package.json";
  if(fs.existsSync(npxPath)){
    const pkg=JSON.parse(fs.readFileSync(npxPath,"utf8"));
    ensure(path.join(REPO,"freellmapi"));
    fs.writeFileSync(path.join(REPO,"freellmapi/package.json"), JSON.stringify(pkg,null,2));
    console.log(` -> freellmapi/package.json v${pkg.version}`);
  }
}catch(e){ console.log(e.message)}
// 10. Gemini/Qwen/Kilocode/etc inventory
console.log("10. Gemini/Qwen/etc...");
ensure(path.join(REPO,"gemini"));
ensure(path.join(REPO,"qwen"));
ensure(path.join(REPO,"kilocode"));
if(fs.existsSync(SRC_GEMINI)){
  try{
    const files=fs.readdirSync(SRC_GEMINI);
    fs.writeFileSync(path.join(REPO,"gemini/source-layout.txt"), files.join("\n"));
    if(fs.existsSync(path.join(SRC_GEMINI,"config"))){
      copyDirSync(path.join(SRC_GEMINI,"config"), path.join(REPO,"gemini/config"));
    }
  }catch{}
}
if(fs.existsSync(SRC_QWEN)){
  if(fs.existsSync(path.join(SRC_QWEN,"settings.json"))){
    let data=JSON.parse(fs.readFileSync(path.join(SRC_QWEN,"settings.json"),"utf8"));
    function redact(o){ for(const k in o){ if(typeof o[k]==="string" && (k.toLowerCase().includes("token")||k.toLowerCase().includes("key"))){ o[k]="${"+k+"}"; } else if(typeof o[k]==="object"&&o[k]) redact(o[k]); } }
    redact(data);
    fs.writeFileSync(path.join(REPO,"qwen/settings.json.example"), JSON.stringify(data,null,2));
  }
  if(fs.existsSync(path.join(SRC_QWEN,".env"))){
    let raw=fs.readFileSync(path.join(SRC_QWEN,".env"),"utf8");
    raw=raw.replace(/=.+/g, "=${REDACTED}");
    fs.writeFileSync(path.join(REPO,"qwen/.env.example"), raw);
  }
  try{ fs.writeFileSync(path.join(REPO,"qwen/source-layout.txt"), fs.readdirSync(SRC_QWEN).join("\n")); }catch{}
}
if(fs.existsSync("C:/Users/PilzIndia/.kilocode")){
  try{ fs.writeFileSync(path.join(REPO,"kilocode/source-layout.txt"), fs.readdirSync("C:/Users/PilzIndia/.kilocode").join("\n")); }catch{}
}
if(fs.existsSync("C:/Users/PilzIndia/.opencode")){
  try{ fs.writeFileSync(path.join(REPO,"tools/opencode-legacy-layout.txt"), fs.readdirSync("C:/Users/PilzIndia/.opencode").join("\n")); }catch{}
}
// tools inventory update
console.log("11. Tools inventory...");
ensure(path.join(REPO,"tools"));
try{
  const globals=execSync("npm list -g --depth=0",{encoding:"utf8"});
  fs.writeFileSync(path.join(REPO,"tools/global-npm-packages.txt"), globals);
}catch(e){
  try{ fs.writeFileSync(path.join(REPO,"tools/global-npm-packages.txt"), e.stdout||e.message); }catch{}
}
try{
  execSync("node --version > \""+path.join(REPO,"tools/node-version.txt")+"\" 2>&1");
  execSync("npm --version > \""+path.join(REPO,"tools/npm-version.txt")+"\" 2>&1");
  execSync("bun --version > \""+path.join(REPO,"tools/bun-version.txt")+"\" 2>&1");
  execSync("git --version > \""+path.join(REPO,"tools/git-version.txt")+"\" 2>&1");
  execSync("gh --version > \""+path.join(REPO,"tools/gh-version.txt")+"\" 2>&1");
  execSync("vercel --version > \""+path.join(REPO,"tools/vercel-version.txt")+"\" 2>&1");
  execSync("ruflo --version > \""+path.join(REPO,"tools/ruflo-version.txt")+"\" 2>&1");
  execSync("openclaw --version > \""+path.join(REPO,"tools/openclaw-version.txt")+"\" 2>&1");
}catch{}
try{
  const bins=execSync("ls -lh \"C:/Users/PilzIndia/.local/bin\" 2>&1 || dir \"C:/Users/PilzIndia/.local/bin\"",{encoding:"utf8"});
  fs.writeFileSync(path.join(REPO,"tools/local-bin-list.txt"), bins);
}catch{}
console.log("done");
