extends "res://scripts/jobs/_stub.gd"
# Machinist: passive reduces tower cost (handled via balance lookup),
# Q drops a temporary auto-turret at feet.

var _drop_scene: PackedScene = preload("res://scenes/Tower.tscn")

func on_skill_q() -> void:
    if cd.q > 0.0: return
    cd.q = 15.0
    var t := _drop_scene.instantiate()
    _owner.get_tree().current_scene.add_child(t)
    t.global_position = _owner.global_position + Vector3(0, 0.5, 0)
    if t.has_method("configure"):
        t.configure("arrow")
    var tw := t.create_tween()
    tw.tween_interval(8.0)
    tw.tween_callback(t.queue_free)
