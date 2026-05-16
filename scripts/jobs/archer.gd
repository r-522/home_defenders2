extends "res://scripts/jobs/_stub.gd"
# アーチャー: 直線状を貫通する矢。

func on_skill_q() -> void:
    if cd.q > 0.0: return
    cd.q = 5.0
    var origin: Vector3 = _owner.global_position
    var dir: Vector3 = _owner.aim_dir().normalized()
    for e in _owner.get_tree().get_nodes_in_group("enemies"):
        var to_e: Vector3 = e.global_position - origin
        var proj: float = to_e.dot(dir)
        if proj < 0 or proj > 30.0:
            continue
        var perp: float = (to_e - dir * proj).length()
        if perp <= 1.5 and e.has_method("take_damage"):
            e.take_damage(60.0)
