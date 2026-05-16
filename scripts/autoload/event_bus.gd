extends Node
# Global event bus. Decouples gameplay systems.

signal home_damaged(amount: float, current_hp: float)
signal home_destroyed()
signal enemy_killed(enemy: Node, reward: int)
signal wave_started(wave_index: int)
signal wave_cleared(wave_index: int)
signal gold_changed(new_gold: int)
signal player_damaged(amount: float)
signal player_died()
signal tower_built(tower: Node)
signal skill_used(skill_id: String)
