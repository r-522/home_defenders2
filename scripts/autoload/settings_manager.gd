extends Node
# キーバインド・グラフィック・オーディオ設定を user://settings.cfg に永続化。

const PATH := "user://settings.cfg"

var graphics := {
    "resolution_scale": 1.0,
    "vsync": true,
    "fps_cap": 60,
    "shadow_quality": 2,
    "msaa": 0,
    "bloom": true,
    "ssao": false,
}

var audio := {
    "master": 1.0,
    "bgm": 0.8,
    "se": 1.0,
}

# アクション名 -> InputEvent 配列
var bindings: Dictionary = {}

func _ready() -> void:
    load_all()
    apply_all()

func apply_all() -> void:
    # 設定を実機（DisplayServer / InputMap / AudioServer）に反映。
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if graphics.vsync else DisplayServer.VSYNC_DISABLED)
    Engine.max_fps = int(graphics.fps_cap)
    for action in bindings.keys():
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        InputMap.action_erase_events(action)
        for ev in bindings[action]:
            InputMap.action_add_event(action, ev)
    for bus_name in ["Master", "BGM", "SE"]:
        var idx := AudioServer.get_bus_index(bus_name)
        if idx == -1:
            continue
        var key = bus_name.to_lower()
        if key == "master":
            AudioServer.set_bus_volume_db(idx, linear_to_db(audio.master))
        elif key == "bgm":
            AudioServer.set_bus_volume_db(idx, linear_to_db(audio.bgm))
        elif key == "se":
            AudioServer.set_bus_volume_db(idx, linear_to_db(audio.se))

func save_all() -> void:
    var cfg := ConfigFile.new()
    for k in graphics.keys():
        cfg.set_value("graphics", k, graphics[k])
    for k in audio.keys():
        cfg.set_value("audio", k, audio[k])
    # キーは keycode、マウスは button_index でシリアライズ。
    for action in bindings.keys():
        var arr: Array = []
        for ev in bindings[action]:
            if ev is InputEventKey:
                arr.append({"type": "key", "code": ev.physical_keycode if ev.physical_keycode != 0 else ev.keycode})
            elif ev is InputEventMouseButton:
                arr.append({"type": "mouse", "button": ev.button_index})
        cfg.set_value("bindings", action, arr)
    cfg.save(PATH)

func load_all() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(PATH) != OK:
        return
    for k in graphics.keys():
        graphics[k] = cfg.get_value("graphics", k, graphics[k])
    for k in audio.keys():
        audio[k] = cfg.get_value("audio", k, audio[k])
    if cfg.has_section("bindings"):
        for action in cfg.get_section_keys("bindings"):
            var arr = cfg.get_value("bindings", action, [])
            var events: Array = []
            for d in arr:
                if d.get("type") == "key":
                    var ek := InputEventKey.new()
                    ek.physical_keycode = int(d.get("code", 0))
                    events.append(ek)
                elif d.get("type") == "mouse":
                    var em := InputEventMouseButton.new()
                    em.button_index = int(d.get("button", 1))
                    events.append(em)
            bindings[action] = events
