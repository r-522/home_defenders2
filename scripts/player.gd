extends CharacterBody3D
# TPS プレイヤーコントローラ。SpringArm3D による視点回転、
# WASD はカメラ Yaw 相対に変換して移動する。

@export var move_speed: float = 7.5
@export var dodge_speed: float = 18.0
@export var dodge_duration: float = 0.35
@export var dodge_cooldown: float = 0.9
@export var gravity: float = 24.0
@export var mouse_sensitivity: float = 0.0025
@export var max_hp: float = 100.0

@onready var yaw: Node3D = $Yaw
@onready var pitch: Node3D = $Yaw/Pitch
@onready var spring: SpringArm3D = $Yaw/Pitch/SpringArm3D
@onready var camera: Camera3D = $Yaw/Pitch/SpringArm3D/Camera3D
@onready var muzzle: Marker3D = $Yaw/Muzzle

var hp: float = 100.0
var dodging: bool = false
var dodge_timer: float = 0.0
var dodge_cd_left: float = 0.0
var dodge_dir: Vector3 = Vector3.ZERO
var attack_cd: float = 0.0

var job_id: String = "fighter"
var job_data: Dictionary = {}
var job_logic: Node = null

const PROJECTILE := preload("res://scenes/Projectile.tscn")

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    job_id = GameState.selected_job_id
    job_data = JobRegistry.get_job(job_id)
    max_hp = float(job_data.get("hp", 100))
    hp = max_hp
    job_logic = JobRegistry.make_skill_handler(job_id, self)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        yaw.rotate_y(-event.relative.x * mouse_sensitivity)
        pitch.rotate_x(-event.relative.y * mouse_sensitivity)
        pitch.rotation.x = clamp(pitch.rotation.x, -1.2, 0.6)
    if event.is_action_pressed("open_settings"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func _physics_process(dt: float) -> void:
    dodge_cd_left = max(0.0, dodge_cd_left - dt)
    attack_cd = max(0.0, attack_cd - dt)

    var input_vec := Vector2(
        Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
        Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
    )
    var forward := -yaw.global_transform.basis.z
    var right := yaw.global_transform.basis.x
    var wish := (right * input_vec.x + forward * input_vec.y)
    wish.y = 0
    if wish.length() > 1.0:
        wish = wish.normalized()

    if dodging:
        dodge_timer -= dt
        velocity.x = dodge_dir.x * dodge_speed
        velocity.z = dodge_dir.z * dodge_speed
        if dodge_timer <= 0.0:
            dodging = false
    else:
        velocity.x = wish.x * move_speed
        velocity.z = wish.z * move_speed
        if Input.is_action_just_pressed("dodge") and dodge_cd_left <= 0.0 and wish.length() > 0.1:
            dodging = true
            dodge_timer = dodge_duration
            dodge_cd_left = dodge_cooldown
            dodge_dir = wish.normalized()

    if not is_on_floor():
        velocity.y -= gravity * dt
    else:
        velocity.y = -0.1

    move_and_slide()

    if Input.is_action_pressed("attack") and attack_cd <= 0.0:
        _basic_attack()

    if job_logic:
        if Input.is_action_just_pressed("skill_q") and job_logic.has_method("on_skill_q"):
            job_logic.on_skill_q()
        if Input.is_action_just_pressed("skill_e") and job_logic.has_method("on_skill_e"):
            job_logic.on_skill_e()
        if Input.is_action_just_pressed("skill_f") and job_logic.has_method("on_skill_f"):
            job_logic.on_skill_f()

func _basic_attack() -> void:
    attack_cd = float(job_data.get("attack_cd", 0.35))
    var p := PROJECTILE.instantiate()
    get_tree().current_scene.add_child(p)
    p.global_transform = muzzle.global_transform
    var dir := -pitch.global_transform.basis.z
    p.launch(dir.normalized(), float(job_data.get("atk", 25)))

func take_damage(amount: float) -> void:
    if dodging:
        return
    hp = max(0.0, hp - amount)
    EventBus.player_damaged.emit(amount)
    if hp <= 0.0:
        EventBus.player_died.emit()

func aim_dir() -> Vector3:
    return -pitch.global_transform.basis.z
