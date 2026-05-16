extends Node3D
# data/waves.json を読み込み、スポーンポイントから敵を出現させる。

@export var enemy_scene: PackedScene
@export var spawn_points_path: NodePath

var spawn_points: Array = []
var current_wave_idx: int = -1
var active_enemies: int = 0
var spawning: bool = false

func _ready() -> void:
    if spawn_points_path != NodePath(""):
        for c in get_node(spawn_points_path).get_children():
            if c is Node3D:
                spawn_points.append(c)
    EventBus.enemy_killed.connect(_on_enemy_killed)

func start_next_wave() -> void:
    current_wave_idx += 1
    if current_wave_idx >= DataLoader.waves.size():
        return
    var wave = DataLoader.waves[current_wave_idx]
    EventBus.wave_started.emit(current_wave_idx)
    _run_wave(wave)

func _run_wave(wave: Dictionary) -> void:
    spawning = true
    var groups: Array = wave.get("groups", [])
    for g in groups:
        var enemy_id: String = g.get("enemy", "grunt")
        var count: int = int(g.get("count", 5))
        var interval: float = float(g.get("interval", 0.6))
        for i in count:
            _spawn_one(enemy_id)
            await get_tree().create_timer(interval).timeout
    spawning = false
    await _wait_until_clear()
    EventBus.wave_cleared.emit(current_wave_idx)
    SaveSystem.record_wave(current_wave_idx + 1)
    await get_tree().create_timer(float(wave.get("rest", 5.0))).timeout
    if GameState.is_running:
        start_next_wave()

func _spawn_one(enemy_id: String) -> void:
    if spawn_points.is_empty() or enemy_scene == null:
        return
    var sp: Node3D = spawn_points[randi() % spawn_points.size()]
    var e := enemy_scene.instantiate()
    get_tree().current_scene.add_child(e)
    e.global_position = sp.global_position
    var data: Dictionary = DataLoader.enemies.get(enemy_id, {})
    if e.has_method("configure"):
        e.configure(data)
    active_enemies += 1

func _on_enemy_killed(_e: Node, _r: int) -> void:
    active_enemies = max(0, active_enemies - 1)

func _wait_until_clear() -> void:
    while active_enemies > 0 or spawning:
        await get_tree().create_timer(0.3).timeout
