extends Node
# WebRTC による P2P 通信の骨格。ホストが Authority となる方式。
# 最小実装は RPC による位置同期のみ。シグナリングは Vercel Edge Function を使用。

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
    # 部屋の作成（自分が Authority になる）。
    room_id = rid
    is_host = true
    _connect_signaling(signaling_url, "host")

func join_room(rid: String, signaling_url: String = SIGNALING_URL_DEFAULT) -> void:
    # 既存の部屋に参加。
    room_id = rid
    is_host = false
    _connect_signaling(signaling_url, "join")

func _connect_signaling(url: String, mode: String) -> void:
    ws = WebSocketPeer.new()
    var full := "%s?room=%s&mode=%s" % [url, room_id, mode]
    var err := ws.connect_to_url(full)
    if err != OK:
        push_warning("シグナリングへの接続に失敗: %s" % err)
        return
    enabled = true
    rtc = WebRTCMultiplayerPeer.new()
    # 本実装の Offer/Answer/ICE 交換は ws の OPEN 確立後に行う。
    # 詳細: https://docs.godotengine.org/en/stable/tutorials/networking/webrtc.html

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
    # TODO: ICE/SDP の完全な折衝。今回の骨格ではスタブのみ。
    pass

@rpc("any_peer", "unreliable", "call_remote")
func sync_player_transform(_peer_id: int, _pos: Vector3, _yaw: float) -> void:
    # TODO: 受信側で補間・クライアント側予測（CSP）を適用する。
    pass
