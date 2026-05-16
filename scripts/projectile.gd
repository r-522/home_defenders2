extends Area3D

@export var speed: float = 40.0
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
    queue_free()

func _on_area(area: Node) -> void:
    if area.has_method("take_damage"):
        area.take_damage(damage)
        queue_free()
