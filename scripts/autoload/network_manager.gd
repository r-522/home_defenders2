extends Node
# WebRTC P2P skeleton. Host = authority. Min impl: position sync via RPC.
# Signaling endpoint is a Vercel Edge Function (see signaling/).

signal peer_joined(peer_id: int)
signal peer_left(peer_id: int)

const SIGNALING_URL_DEFAULT := "wss://YOUR-VERCEL-DEPLOYMENT/api/signal"

var rtc: WebRTCMultiplayerPeer = null
var ws: WebSocketPeer = null
var room_id: String = ""
var is_host: bool = false
var local_peer_id: int = 1
var enabled: bool = false

func host_room(rid: String, signaling_url: String = SIGNALING_URL_DEFAULT) -> void:
    room_id = rid
    is_host = true
    _connect_signaling(signaling_url, "host")

func join_room(rid: String, signaling_url: String = SIGNALING_URL_DEFAULT) -> void:
    room_id = rid
    is_host = false
    _connect_signaling(signaling_url, "join")

func _connect_signaling(url: String, mode: String) -> void:
    ws = WebSocketPeer.new()
    var full := "%s?room=%s&mode=%s" % [url, room_id, mode]
    var err := ws.connect_to_url(full)
    if err != OK:
        push_warning("Signaling connect failed: %s" % err)
        return
    enabled = true
    rtc = WebRTCMultiplayerPeer.new()
    # Real offer/answer/ICE exchange is wired in _process when ws state is OPEN.
    # See docs at https://docs.godotengine.org/en/stable/tutorials/networking/webrtc.html

func _process(_dt: float) -> void:
    if not enabled or ws == null:
        return
    ws.poll()
    var state := ws.get_ready_state()
    while state == WebSocketPeer.STATE_OPEN and ws.get_available_packet_count() > 0:
        var pkt := ws.get_packet().get_string_from_utf8()
        var msg = JSON.parse_string(pkt)
        if msg is Dictionary:
            _handle_signal(msg)

func _handle_signal(_msg: Dictionary) -> void:
    # TODO: full ICE/SDP plumbing. Stubbed for first iteration.
    pass

@rpc("any_peer", "unreliable", "call_remote")
func sync_player_transform(_peer_id: int, _pos: Vector3, _yaw: float) -> void:
    # TODO: apply remote transform with interpolation (CSP) on receiving side.
    pass
