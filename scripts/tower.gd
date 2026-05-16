extends StaticBody3D
# Generic tower. Behaviour driven by data (kind: "arrow" | "cannon" | "slow").

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

func _on_enter(b: Node) -> void:
    if b.is_in_group("enemies"):
        _targets.append(b)

func _on_exit(b: Node) -> void:
    _targets.erase(b)

func _process(dt: float) -> void:
    _cd = max(0.0, _cd - dt)
    _targets = _targets.filter(func(t): return is_instance_valid(t))
    if _cd > 0.0 or _targets.is_empty():
        return
    var target: Node3D = _targets[0]
    _fire(target)
    _cd = fire_cd

func _fire(target: Node3D) -> void:
    match kind:
        "slow":
            if target.has_method("apply_slow"):
                target.apply_slow(slow_factor, slow_duration)
            if target.has_method("take_damage"):
                target.take_damage(damage)
        "cannon":
            # Splash AOE at target position.
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
