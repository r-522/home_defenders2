extends Node
# Persistent runtime state: gold, wave, selected job, etc.

var gold: int = 200
var current_wave: int = 0
var selected_job_id: String = "fighter"
var home_max_hp: float = 1000.0
var home_hp: float = 1000.0
var is_running: bool = false

func reset() -> void:
    gold = 200
    current_wave = 0
    home_hp = home_max_hp
    is_running = true
    EventBus.gold_changed.emit(gold)

func add_gold(amount: int) -> void:
    gold += amount
    EventBus.gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
    if gold < amount:
        return false
    gold -= amount
    EventBus.gold_changed.emit(gold)
    return true

func damage_home(amount: float) -> void:
    home_hp = max(0.0, home_hp - amount)
    EventBus.home_damaged.emit(amount, home_hp)
    if home_hp <= 0.0 and is_running:
        is_running = false
        EventBus.home_destroyed.emit()
