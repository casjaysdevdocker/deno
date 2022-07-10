import { serve } from 'https://deno.land/std@0.77.0/http/server.ts';

const PORT = 1993;
const s = serve(`0.0.0.0:${PORT}`);
const body = new TextEncoder().encode('Hello World\n');

console.log(`Server started on port ${PORT}`);
for await (const req of s) {
  req.respond({ body });
}
