extends StaticBody3D
# 汎用タワー。挙動は data/towers.json の種別（arrow / cannon / slow）で切替。

@export var kind: String = "arrow"

var range_r: float = 14.0
var fire_cd: float = 0.7
var damage: float = 18.0
var slow_factor: float = 0.5
var slow_duration: float = 1.2
var splash: float = 0.0

@onready var range_area: Area3D = $RangeArea
@onready var muzzle: Marker3D = $Muzzle

var _cd: float = 0.0
var _targets: Array = []

const PROJECTILE := preload("res://scenes/Projectile.tscn")

func configure(kind_id: String) -> void:
    kind = kind_id
    var d: Dictionary = DataLoader.towers.get(kind_id, {})
    range_r = float(d.get("range", range_r))
    fire_cd = float(d.get("fire_cd", fire_cd))
    damage = float(d.get("damage", damage))
    splash = float(d.get("splash", splash))
    slow_factor = float(d.get("slow_factor", slow_factor))
    slow_duration = float(d.get("slow_duration", slow_duration))
    var cs := range_area.get_node_or_null("CollisionShape3D")
    if cs and cs.shape is SphereShape3D:
        (cs.shape as SphereShape3D).radius = range_r

func _ready() -> void:
    range_area.body_entered.connect(_on_enter)
    range_area.body_exited.connect(_on_exit)
    _retint_crystal()

func _retint_crystal() -> void:
    var crystal := get_node_or_null("Visual/Crystal")
    var light := get_node_or_null("Visual/CrystalLight")
    if crystal == null:
        return
    var col := Color(0.5, 0.85, 1.0)
    match kind:
        "cannon":
            col = Color(1.0, 0.55, 0.18)
        "slow":
            col = Color(0.55, 0.95, 1.0)
        _:
            col = Color(0.55, 0.85, 0.45)
    if crystal.material is StandardMaterial3D:
        var m: StandardMaterial3D = (crystal.material as StandardMaterial3D).duplicate()
        m.albedo_color = col
        m.emission = col
        m.emission_energy_multiplier = 1.8
        crystal.material = m
    if light:
        light.light_color = col

func _on_enter(b: Node) -> void:
    if b.is_in_group("enemies"):
        _targets.append(b)

func _on_exit(b: Node) -> void:
    _targets.erase(b)

func _process(dt: float) -> void:
    _cd = max(0.0, _cd - dt)
    _targets = _targets.filter(func(t): return is_instance_valid(t))
    # クリスタルのゆらぎ
    var crystal := get_node_or_null("Visual/Crystal")
    if crystal:
        crystal.rotation.y += dt * 1.5
    if _cd > 0.0 or _targets.is_empty():
        return
    var target: Node3D = _targets[0]
    _fire(target)
    _cd = fire_cd

func _fire(target: Node3D) -> void:
    _muzzle_flash()
    match kind:
        "slow":
            if target.has_method("apply_slow"):
                target.apply_slow(slow_factor, slow_duration)
            if target.has_method("take_damage"):
                target.take_damage(damage)
        "cannon":
            # ターゲット地点を中心とした範囲ダメージ。
            for e in get_tree().get_nodes_in_group("enemies"):
                if e.global_position.distance_to(target.global_position) <= splash:
                    if e.has_method("take_damage"):
                        e.take_damage(damage)
        _:
            var p := PROJECTILE.instantiate()
            get_tree().current_scene.add_child(p)
            p.global_transform = muzzle.global_transform
            var dir := (target.global_position - muzzle.global_position).normalized()
            p.launch(dir, damage)

func _muzzle_flash() -> void:
    # 砲口の閃光（小さなパーティクル）
    var p := CPUParticles3D.new()
    p.amount = 8
    p.one_shot = true
    p.emitting = true
    p.lifetime = 0.18
    p.explosiveness = 1.0
    p.direction = Vector3(0, 0, -1)
    p.spread = 30.0
    p.initial_velocity_min = 1.0
    p.initial_velocity_max = 2.5
    p.scale_amount_min = 0.08
    p.scale_amount_max = 0.16
    var col := Color(1.0, 0.85, 0.4)
    if kind == "slow":
        col = Color(0.6, 0.9, 1.0)
    elif kind == "cannon":
        col = Color(1.0, 0.5, 0.18)
    p.color = col
    add_child(p)
    p.global_transform = muzzle.global_transform
    var tw := p.create_tween()
    tw.tween_interval(0.4)
    tw.tween_callback(p.queue_free)
