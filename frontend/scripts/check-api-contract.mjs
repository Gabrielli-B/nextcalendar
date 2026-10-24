#!/usr/bin/env node
/**
 * Check de contrato estático frontend → backend.
 *
 * Extrai as chamadas `api.<method>(...)` de frontend/src (axios instance com
 * baseURL .../api/v1) e valida method+path contra o snapshot versionado do
 * OpenAPI do backend (backend/specs/openapi.json).
 *
 * Regenerar o snapshot quando o backend mudar:
 *   make backend-openapi-dump      (backend precisa estar no ar)
 *
 * Uso:
 *   npm run check:api
 *   node scripts/check-api-contract.mjs [--openapi caminho] [--verbose]
 *
 * Exit 1 se alguma chamada apontar para path/método inexistente.
 */

import { readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const FRONTEND_SRC = resolve(__dirname, '..', 'src');
const ROOT = resolve(__dirname, '..', '..');
const DEFAULT_OPENAPI = resolve(ROOT, 'backend', 'specs', 'openapi.json');

const args = process.argv.slice(2);
const openapiPath = (() => {
  const i = args.indexOf('--openapi');
  return i >= 0 && args[i + 1] ? resolve(args[i + 1]) : DEFAULT_OPENAPI;
})();
const verbose = args.includes('--verbose');

const METHODS = ['get', 'post', 'put', 'patch', 'delete'];
const callRe = /\bapi\.(get|post|put|patch|delete)\b/g;

function walk(dir, out = []) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) walk(p, out);
    else if (/\.[tT]sx?$/.test(p)) out.push(p);
  }
  return out;
}

/** Devolve o argumento literal da chamada, ou null. */
function readStringArg(src, start) {
  let i = start;
  while (i < src.length && /\s/.test(src[i])) i++;
  if (src[i] !== '(') return null;
  i++;
  while (i < src.length && /\s/.test(src[i])) i++;
  const q = src[i];
  if (q !== '`' && q !== "'" && q !== '"') return null;
  let buf = '';
  for (let j = i + 1; j < src.length && src[j] !== q; j++) {
    if (src[j] === '\\') {
      buf += src[j + 1];
      j++;
    } else buf += src[j];
  }
  return buf;
}

/** Pula genéricos `api.get<Page<T>>(` antes do parêntese. */
function skipGenerics(src, i) {
  if (src[i] !== '<') return i;
  let depth = 0;
  while (i < src.length) {
    if (src[i] === '<') depth++;
    else if (src[i] === '>') {
      depth--;
      if (depth === 0) return i + 1;
    }
    i++;
  }
  return i;
}

/** ${...} → {x}; devolve null se o caminho não for resolvível estaticamente. */
function normalizePath(raw) {
  const normalized = raw.replace(/\$\{[^}]*\}/g, '{x}');
  if (raw.startsWith('${') || /\$\{[^}]*\(/.test(raw)) return null;
  return normalized;
}

function segments(path) {
  return path.replace(/^\/api\/v1/, '').replace(/^\/+|\/+$/g, '').split('/');
}

function sameSegments(a, b) {
  if (a.length !== b.length) return false;
  return a.every((seg, i) => seg === b[i] || (seg.startsWith('{') && b[i].startsWith('{')));
}

// ── main ──────────────────────────────────────────────────────────────────────

let spec;
try {
  spec = JSON.parse(readFileSync(openapiPath, 'utf8'));
} catch (e) {
  console.error(`✗ Não li o OpenAPI em ${relative(ROOT, openapiPath)}: ${e.message}`);
  console.error('  Rode `make backend-openapi-dump` com o backend no ar.');
  process.exit(2);
}

const known = new Map(); // METHOD → [paths]
for (const [path, ops] of Object.entries(spec.paths ?? {})) {
  for (const m of Object.keys(ops)) {
    if (!METHODS.includes(m)) continue;
    const M = m.toUpperCase();
    if (!known.has(M)) known.set(M, []);
    known.get(M).push(path);
  }
}

const calls = [];
for (const file of walk(FRONTEND_SRC)) {
  const src = readFileSync(file, 'utf8');
  callRe.lastIndex = 0;
  for (let m; (m = callRe.exec(src)); ) {
    const arg = readStringArg(src, skipGenerics(src, m.index + m[0].length));
    if (arg == null) continue;
    calls.push({
      file: relative(FRONTEND_SRC, file),
      line: src.slice(0, m.index).split('\n').length,
      method: m[1].toUpperCase(),
      raw: arg,
      path: normalizePath(arg),
    });
  }
}

const errors = [];
const dynamic = [];
const matched = new Set();

for (const c of calls) {
  if (c.path == null) {
    dynamic.push(c);
    continue;
  }
  const candidates = known.get(c.method) ?? [];
  const hit = candidates.find((p) => sameSegments(segments(c.path), segments(p)));
  if (hit) matched.add(`${c.method} ${hit}`);
  else errors.push(c);
}

console.log(`OpenAPI: ${relative(ROOT, openapiPath)} (${known.size} métodos)`);
console.log(`Chamadas analisadas em frontend/src: ${calls.length}`);
console.log(`  casam:                     ${calls.length - errors.length - dynamic.length}`);
console.log(`  dinâmicas (não checáveis): ${dynamic.length}`);
console.log(`  divergentes:               ${errors.length}`);

if (dynamic.length && verbose) {
  console.log('\n— dinâmicas —');
  for (const c of dynamic) console.log(`  ${c.file}:${c.line}: ${c.method} ${c.raw}`);
}

if (errors.length) {
  console.error('\n✗ Chamadas sem correspondência no OpenAPI do backend:');
  for (const c of errors) console.error(`  ${c.file}:${c.line}: ${c.method} ${c.raw}`);
  process.exit(1);
}

if (verbose) {
  const unused = [];
  for (const [M, paths] of known) {
    for (const p of paths) {
      if (p.startsWith('/api/') && !matched.has(`${M} ${p}`)) unused.push(`${M} ${p}`);
    }
  }
  console.log(`\n— endpoints do backend não usados pelo frontend (${unused.length}) —`);
  for (const u of unused.sort()) console.log(`  ${u}`);
}

console.log('\n✓ Contrato OK: todo path/método chamado existe no backend.');
