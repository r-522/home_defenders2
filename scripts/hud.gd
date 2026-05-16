extends CanvasLayer

@onready var hp_label: Label = $Root/Top/HomeHP
@onready var gold_label: Label = $Root/Top/Gold
@onready var wave_label: Label = $Root/Top/Wave
@onready var build_hint: Label = $Root/BuildHint
@onready var game_over: Panel = $Root/GameOver

func _ready() -> void:
    EventBus.gold_changed.connect(_on_gold)
    EventBus.home_damaged.connect(_on_hp)
    EventBus.wave_started.connect(_on_wave)
    EventBus.home_destroyed.connect(_on_game_over)
    _on_gold(GameState.gold)
    _on_hp(0.0, GameState.home_hp)

func _on_gold(g: int) -> void:
    gold_label.text = "Gold: %d" % g

func _on_hp(_dmg: float, hp: float) -> void:
    hp_label.text = "Home HP: %d / %d" % [int(hp), int(GameState.home_max_hp)]

func _on_wave(idx: int) -> void:
    wave_label.text = "Wave: %d" % (idx + 1)

func _on_game_over() -> void:
    game_over.visible = true

func _process(_dt: float) -> void:
    build_hint.visible = true
    build_hint.text = "[B] Build  [1] Arrow  [2] Cannon  [3] Slow  [LMB] Attack/Place  [Shift] Dodge  [ESC] Cursor"
