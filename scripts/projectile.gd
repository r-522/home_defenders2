extends Area3D
# 発射体。ヒット時にスパーク VFX を生成して消滅する。

@export var speed: float = 42.0
@export var lifetime: float = 2.5

var damage: float = 25.0
var _dir: Vector3 = Vector3.FORWARD
var _t: float = 0.0

func _ready() -> void:
    body_entered.connect(_on_hit)
    area_entered.connect(_on_area)

func launch(direction: Vector3, dmg: float) -> void:
    _dir = direction
    damage = dmg

func _process(dt: float) -> void:
    _t += dt
    global_position += _dir * speed * dt
    if _t > lifetime:
        queue_free()

func _on_hit(body: Node) -> void:
    if body.has_method("take_damage"):
        body.take_damage(damage)
    _spawn_spark()
    queue_free()

func _on_area(area: Node) -> void:
    if area.has_method("take_damage"):
        area.take_damage(damage)
        _spawn_spark()
        queue_free()

func _spawn_spark() -> void:
    var p := CPUParticles3D.new()
    p.amount = 16
    p.one_shot = true
    p.emitting = true
    p.lifetime = 0.35
    p.explosiveness = 1.0
    p.direction = Vector3(0, 1, 0)
    p.spread = 90.0
    p.gravity = Vector3(0, -3, 0)
    p.initial_velocity_min = 2.0
    p.initial_velocity_max = 5.0
    p.scale_amount_min = 0.05
    p.scale_amount_max = 0.12
    p.color = Color(1, 0.9, 0.5)
    get_tree().current_scene.add_child(p)
    p.global_position = global_position
    var tw := p.create_tween()
    tw.tween_interval(0.6)
    tw.tween_callback(p.queue_free)
