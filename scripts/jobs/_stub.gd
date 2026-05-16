extends Node
# Placeholder skill logic for jobs not yet specialised.
# Each Q/E/F is a usable AOE pulse + cooldown so the kit feels alive.

var _owner: Node = null
var cd: Dictionary = {"q": 0.0, "e": 0.0, "f": 0.0}

func init(o: Node) -> void:
    _owner = o
    set_process(true)

func _process(dt: float) -> void:
    for k in cd.keys():
        cd[k] = max(0.0, cd[k] - dt)

func _pulse(radius: float, dmg: float, color: Color) -> void:
    var ind := MeshInstance3D.new()
    var sm := SphereMesh.new()
    sm.radius = radius
    sm.height = radius * 2.0
    ind.mesh = sm
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(color.r, color.g, color.b, 0.25)
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    ind.material_override = mat
    _owner.get_parent().add_child(ind)
    ind.global_position = _owner.global_position
    for e in _owner.get_tree().get_nodes_in_group("enemies"):
        if e.global_position.distance_to(_owner.global_position) <= radius and e.has_method("take_damage"):
            e.take_damage(dmg)
    var tw := ind.create_tween()
    tw.tween_property(ind, "scale", Vector3.ONE * 1.4, 0.25)
    tw.tween_callback(ind.queue_free)

func on_skill_q() -> void:
    if cd.q > 0.0: return
    cd.q = 6.0
    _pulse(6.0, 30.0, Color(0.6, 0.9, 1.0))
    EventBus.skill_used.emit("q")

func on_skill_e() -> void:
    if cd.e > 0.0: return
    cd.e = 10.0
    _pulse(9.0, 45.0, Color(1.0, 0.8, 0.3))
    EventBus.skill_used.emit("e")

func on_skill_f() -> void:
    if cd.f > 0.0: return
    cd.f = 20.0
    _pulse(12.0, 80.0, Color(1.0, 0.4, 0.9))
    EventBus.skill_used.emit("f")
