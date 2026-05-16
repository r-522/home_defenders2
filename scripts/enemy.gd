extends CharacterBody3D
# NavigationAgent3D で「おうち」へ進軍し、接触時にダメージを与える。

@export var move_speed: float = 3.5
@export var max_hp: float = 60.0
@export var contact_damage: float = 10.0
@export var attack_cd: float = 1.0
@export var reward_gold: int = 8

@onready var agent: NavigationAgent3D = $NavigationAgent3D

var hp: float = 60.0
var home_ref: Node3D = null
var _atk_timer: float = 0.0
var slow_factor: float = 1.0

func _ready() -> void:
    hp = max_hp
    add_to_group("enemies")
    call_deferred("_setup_target")

func _setup_target() -> void:
    var homes := get_tree().get_nodes_in_group("home")
    if homes.size() > 0:
        home_ref = homes[0]
        agent.target_position = home_ref.global_position

func configure(data: Dictionary) -> void:
    max_hp = float(data.get("hp", max_hp))
    hp = max_hp
    move_speed = float(data.get("speed", move_speed))
    contact_damage = float(data.get("damage", contact_damage))
    reward_gold = int(data.get("reward", reward_gold))
    var scale_val := float(data.get("scale", 1.0))
    scale = Vector3.ONE * scale_val

func _physics_process(dt: float) -> void:
    _atk_timer = max(0.0, _atk_timer - dt)
    if home_ref == null:
        return
    if global_position.distance_to(home_ref.global_position) < 2.5:
        if _atk_timer <= 0.0:
            home_ref.take_damage(contact_damage)
            _atk_timer = attack_cd
        return
    var next: Vector3 = agent.get_next_path_position()
    var dir := (next - global_position)
    dir.y = 0
    if dir.length() > 0.05:
        dir = dir.normalized()
        velocity.x = dir.x * move_speed * slow_factor
        velocity.z = dir.z * move_speed * slow_factor
        look_at(global_position + Vector3(dir.x, 0, dir.z), Vector3.UP)
    velocity.y -= 18.0 * dt
    move_and_slide()

func take_damage(amount: float) -> void:
    hp -= amount
    if hp <= 0:
        GameState.add_gold(reward_gold)
        EventBus.enemy_killed.emit(self, reward_gold)
        queue_free()

func apply_slow(factor: float, duration: float) -> void:
    slow_factor = clamp(factor, 0.1, 1.0)
    var tw := create_tween()
    tw.tween_interval(duration)
    tw.tween_callback(func(): slow_factor = 1.0)
