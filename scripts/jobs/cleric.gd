extends "res://scripts/jobs/_stub.gd"
# Cleric: heal self & restore home small chunk.

func on_skill_q() -> void:
    if cd.q > 0.0: return
    cd.q = 12.0
    if _owner.has_method("take_damage"):
        _owner.hp = min(_owner.max_hp, _owner.hp + 40.0)
    GameState.home_hp = min(GameState.home_max_hp, GameState.home_hp + 50.0)
    EventBus.home_damaged.emit(0.0, GameState.home_hp)
