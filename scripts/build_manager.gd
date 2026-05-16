extends Node3D
# Build mode: ray-pick a ground tile, snap to grid, spend gold, place tower.

@export var grid_size: float = 2.0
@export var player_path: NodePath
@export var ghost_material: StandardMaterial3D

const TOWER_SCENE := preload("res://scenes/Tower.tscn")

var build_mode: bool = false
var selected_kind: String = "arrow"
var ghost: MeshInstance3D = null
var _camera: Camera3D = null

func _ready() -> void:
    set_process(true)
    var p = get_node_or_null(player_path)
    if p:
        _camera = p.get_node_or_null("Yaw/Pitch/SpringArm3D/Camera3D")

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("build_menu"):
        toggle_build_mode()
    if build_mode:
        if event is InputEventKey and event.pressed:
            match event.keycode:
                KEY_1: selected_kind = "arrow"
                KEY_2: selected_kind = "cannon"
                KEY_3: selected_kind = "slow"
        if event.is_action_pressed("attack"):
            _try_place()
            get_viewport().set_input_as_handled()

func toggle_build_mode() -> void:
    build_mode = not build_mode
    if build_mode:
        _ensure_ghost()
    elif ghost:
        ghost.visible = false

func _ensure_ghost() -> void:
    if ghost == null:
        ghost = MeshInstance3D.new()
        var bx := BoxMesh.new()
        bx.size = Vector3(1.6, 2.0, 1.6)
        ghost.mesh = bx
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.4, 1.0, 0.5, 0.4)
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        ghost.material_override = mat
        add_child(ghost)
    ghost.visible = true

func _process(_dt: float) -> void:
    if not build_mode or _camera == null:
        return
    var pos := _aim_ground()
    if pos == null:
        return
    ghost.global_position = _snap(pos)

func _aim_ground():
    var space := get_world_3d().direct_space_state
    var from := _camera.global_position
    var to := from + (-_camera.global_transform.basis.z) * 60.0
    var q := PhysicsRayQueryParameters3D.create(from, to)
    q.collision_mask = 1 # World layer
    var r := space.intersect_ray(q)
    if r.is_empty():
        return null
    return r.position

func _snap(v: Vector3) -> Vector3:
    return Vector3(
        round(v.x / grid_size) * grid_size,
        v.y + 1.0,
        round(v.z / grid_size) * grid_size
    )

func _try_place() -> void:
    var d: Dictionary = DataLoader.towers.get(selected_kind, {})
    var cost := int(d.get("cost", 50))
    if not GameState.spend_gold(cost):
        return
    var t := TOWER_SCENE.instantiate()
    get_tree().current_scene.add_child(t)
    t.global_position = ghost.global_position
    if t.has_method("configure"):
        t.configure(selected_kind)
    EventBus.tower_built.emit(t)
