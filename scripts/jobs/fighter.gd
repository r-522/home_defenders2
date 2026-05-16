extends "res://scripts/jobs/_stub.gd"
# ファイター: バランス型。Q=シールドバッシュ（吹き飛ばし）、E/F は共通スタブ。

func on_skill_q() -> void:
    if cd.q > 0.0: return
    cd.q = 4.0
    _pulse(4.0, 40.0, Color(0.9, 0.9, 1.0))
    for e in _owner.get_tree().get_nodes_in_group("enemies"):
        if e.global_position.distance_to(_owner.global_position) <= 4.0:
            var dir: Vector3 = (e.global_position - _owner.global_position).normalized() * 6.0
            if e is CharacterBody3D:
                e.velocity = Vector3(dir.x, 4.0, dir.z)
