extends StaticBody3D
# 拠点（おうち）。被弾時に屋根を赤くフラッシュさせ、画面を揺らす。

func _ready() -> void:
    add_to_group("home")

func take_damage(amount: float) -> void:
    GameState.damage_home(amount)
    _flash_damage()
    # プレイヤーのカメラを揺らす
    var players := get_tree().get_nodes_in_group("players")
    for p in players:
        if p.has_method("add_camera_shake"):
            p.add_camera_shake(0.5, 0.18)
    var local_p := get_tree().current_scene.get_node_or_null("Player")
    if local_p and local_p.has_method("add_camera_shake"):
        local_p.add_camera_shake(0.5, 0.18)

func _flash_damage() -> void:
    var visual := get_node_or_null("Visual")
    if visual == null:
        return
    for c in visual.get_children():
        if c is CSGShape3D and c.material is StandardMaterial3D:
            var m: StandardMaterial3D = c.material
            var orig: Color = m.albedo_color
            m.albedo_color = Color(1, 0.45, 0.4)
            var tw := create_tween()
            tw.tween_interval(0.10)
            tw.tween_callback(func(): m.albedo_color = orig)
            break
