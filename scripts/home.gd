extends StaticBody3D

func _ready() -> void:
    add_to_group("home")

func take_damage(amount: float) -> void:
    GameState.damage_home(amount)
