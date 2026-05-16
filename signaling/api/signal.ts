// Vercel Edge Function: minimal WebSocket signaling relay for WebRTC.
// Rooms are in-memory per edge instance — fine for casual co-op.
// For production cross-region rooms, swap to Vercel KV / Upstash Redis pub-sub.

export const config = { runtime: "edge" };

type Peer = { socket: WebSocket; room: string; mode: "host" | "join" };
const ROOMS = new Map<string, Set<Peer>>();

export default function handler(req: Request): Response {
  const { searchParams } = new URL(req.url);
  const room = searchParams.get("room");
  const mode = (searchParams.get("mode") ?? "join") as "host" | "join";
  if (!room) return new Response("missing room", { status: 400 });

  // @ts-expect-error WebSocketPair is provided by the Edge runtime
  const pair = new WebSocketPair();
  const client = pair[0];
  const server = pair[1];
  server.accept();

  const peer: Peer = { socket: server, room, mode };
  if (!ROOMS.has(room)) ROOMS.set(room, new Set());
  ROOMS.get(room)!.add(peer);

  server.addEventListener("message", (ev: MessageEvent) => {
    const bucket = ROOMS.get(room);
    if (!bucket) return;
    for (const p of bucket) {
      if (p !== peer && p.socket.readyState === 1) {
        p.socket.send(ev.data as string);
      }
    }
  });

  server.addEventListener("close", () => {
    ROOMS.get(room)?.delete(peer);
    if (ROOMS.get(room)?.size === 0) ROOMS.delete(room);
  });

  return new Response(null, { status: 101, webSocket: client } as ResponseInit);
}
