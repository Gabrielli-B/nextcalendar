/**
 * Reverse proxy same-origin para expor o projeto na internet.
 *
 *   /api/**, /v3/**, /swagger-ui/**, /actuator/**  -> backend  :8080
 *   todo o resto (inclui WebSocket do Metro HMR)    -> Expo web :8081
 *
 * Como front e API passam a compartilhar a MESMA origem pública, o navegador
 * não dispara CORS — não é preciso mexer em WebConfig.java.
 *
 * Uso: node scripts/expose/proxy.mjs
 * Env: EXPOSE_PORT (8085), BACKEND_PORT (8080), WEB_PORT (8081)
 */
import http from 'node:http';
import net from 'node:net';

const EXPOSE_PORT = Number(process.env.EXPOSE_PORT || 8085);
const BACKEND = { host: '127.0.0.1', port: Number(process.env.BACKEND_PORT || 8080) };
const WEB = { host: '127.0.0.1', port: Number(process.env.WEB_PORT || 8081) };

const BACKEND_PREFIXES = ['/api/', '/v3/', '/swagger-ui', '/swagger-ui/', '/actuator', '/error'];

function pickTarget(url) {
  const path = url || '/';
  return BACKEND_PREFIXES.some((p) => path === p || path.startsWith(p)) ? BACKEND : WEB;
}

function forward(req, res, target) {
  // Preserva o Host original (ex.: https://xxx.trycloudflare.com): assim o Spring
  // enxerga a requisição como same-origin e não bloqueia com "Invalid CORS request".
  const headers = { ...req.headers, host: req.headers.host || `${target.host}:${target.port}` };
  delete headers['accept-encoding']; // mantém o corpo legível ao reescrever

  const proxyReq = http.request(
    { host: target.host, port: target.port, path: req.url, method: req.method, headers },
    (proxyRes) => {
      res.writeHead(proxyRes.statusCode || 502, proxyRes.headers);
      proxyRes.pipe(res);
    }
  );

  proxyReq.on('error', (err) => {
    if (!res.headersSent) {
      res.writeHead(502, { 'content-type': 'text/plain; charset=utf-8' });
    }
    res.end(`Bad gateway (${target.host}:${target.port}): ${err.message}`);
  });

  req.pipe(proxyReq);
}

const server = http.createServer((req, res) => {
  const target = pickTarget(req.url);
  forward(req, res, target);
});

// WebSocket (HMR do Metro e do React Refresh)
server.on('upgrade', (req, socket, head) => {
  const target = WEB; // só o Expo fala WebSocket
  const upstream = net.connect(target.port, target.host, () => {
    const lines = [`${req.method} ${req.url} HTTP/1.1`];
    for (const [key, value] of Object.entries(req.headers)) {
      if (Array.isArray(value)) value.forEach((v) => lines.push(`${key}: ${v}`));
      else if (value !== undefined) lines.push(`${key}: ${value}`);
    }
    upstream.write(lines.join('\r\n') + '\r\n\r\n');
    if (head?.length) upstream.write(head);
    socket.pipe(upstream).pipe(socket);
  });
  upstream.on('error', () => socket.destroy());
  socket.on('error', () => upstream.destroy());
});

server.listen(EXPOSE_PORT, () => {
  console.log(
    `[expose] proxy em :${EXPOSE_PORT}  api->:${BACKEND.port}  web->:${WEB.port}`
  );
});
