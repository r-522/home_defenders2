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
var _flash_t: float = 0.0
var _orig_emission: Color = Color(1, 0.18, 0.05, 1)

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
    _flash_t = 0.12
    _set_body_emission(Color(1.0, 0.4, 0.4, 1), 1.5)
    if hp <= 0:
        GameState.add_gold(reward_gold)
        EventBus.enemy_killed.emit(self, reward_gold)
        _spawn_death_vfx()
        queue_free()

func _process(dt: float) -> void:
    if _flash_t > 0.0:
        _flash_t -= dt
        if _flash_t <= 0.0:
            _set_body_emission(Color(0, 0, 0, 1), 0.0)

func _set_body_emission(col: Color, energy: float) -> void:
    var rig: Node3D = get_node_or_null("Rig")
    if rig == null:
        return
    for c in rig.get_children():
        if c is CSGShape3D and c.material is StandardMaterial3D:
            var m: StandardMaterial3D = c.material
            m.emission_enabled = energy > 0.0
            m.emission = col
            m.emission_energy_multiplier = energy

func _spawn_death_vfx() -> void:
    var p := CPUParticles3D.new()
    p.amount = 30
    p.lifetime = 0.6
    p.one_shot = true
    p.emitting = true
    p.explosiveness = 0.9
    p.direction = Vector3(0, 1, 0)
    p.spread = 80.0
    p.gravity = Vector3(0, -1.0, 0)
    p.initial_velocity_min = 2.5
    p.initial_velocity_max = 5.0
    p.scale_amount_min = 0.10
    p.scale_amount_max = 0.20
    p.color = Color(0.65, 0.18, 0.35, 1)
    get_tree().current_scene.add_child(p)
    p.global_position = global_position + Vector3(0, 0.6, 0)
    var tw := p.create_tween()
    tw.tween_interval(1.0)
    tw.tween_callback(p.queue_free)

func apply_slow(factor: float, duration: float) -> void:
    slow_factor = clamp(factor, 0.1, 1.0)
    var tw := create_tween()
    tw.tween_interval(duration)
    tw.tween_callback(func(): slow_factor = 1.0)
