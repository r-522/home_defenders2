extends "res://scripts/jobs/_stub.gd"
# メイジ: 照準先に着弾する範囲メテオ。

func on_skill_q() -> void:
    if cd.q > 0.0: return
    cd.q = 8.0
    var aim_pos: Vector3 = _owner.global_position + _owner.aim_dir() * 12.0
    var ind := MeshInstance3D.new()
    var sm := SphereMesh.new()
    sm.radius = 5.0
    sm.height = 10.0
    ind.mesh = sm
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(1.0, 0.5, 0.1, 0.4)
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    ind.material_override = mat
    _owner.get_parent().add_child(ind)
    ind.global_position = aim_pos
    for e in _owner.get_tree().get_nodes_in_group("enemies"):
        if e.global_position.distance_to(aim_pos) <= 5.0 and e.has_method("take_damage"):
            e.take_damage(70.0)
    var tw := ind.create_tween()
    tw.tween_property(ind, "scale", Vector3.ONE * 0.1, 0.35)
    tw.tween_callback(ind.queue_free)
