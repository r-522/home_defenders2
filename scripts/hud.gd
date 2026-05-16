extends CanvasLayer
# HUD: HP/ゴールド/ウェーブ表示、スキル CD、ウェーブ開始バナー、ゲームオーバー。

@onready var hp_bar: ProgressBar = $Root/TopLeft/HPBar
@onready var hp_label: Label = $Root/TopLeft/HomeHP
@onready var gold_label: Label = $Root/TopRight/Gold
@onready var wave_label: Label = $Root/TopCenter/Wave
@onready var wave_banner: Label = $Root/WaveBanner
@onready var build_hint: Label = $Root/BottomPanel/BuildHint
@onready var skill_q: Label = $Root/BottomPanel/Skills/SkillQ
@onready var skill_e: Label = $Root/BottomPanel/Skills/SkillE
@onready var skill_f: Label = $Root/BottomPanel/Skills/SkillF
@onready var game_over: Panel = $Root/GameOver

func _ready() -> void:
    EventBus.gold_changed.connect(_on_gold)
    EventBus.home_damaged.connect(_on_hp)
    EventBus.wave_started.connect(_on_wave)
    EventBus.home_destroyed.connect(_on_game_over)
    hp_bar.max_value = GameState.home_max_hp
    _on_gold(GameState.gold)
    _on_hp(0.0, GameState.home_hp)
    build_hint.text = "[B] 建設  [1/2/3] アロー / キャノン / スロウ  [左クリック] 攻撃・設置  [Shift] 回避  [Q/E/F] スキル  [ESC] カーソル"

func _on_gold(g: int) -> void:
    gold_label.text = "◆ ゴールド: %d" % g

func _on_hp(_dmg: float, hp: float) -> void:
    hp_bar.value = hp
    hp_label.text = "%d / %d" % [int(hp), int(GameState.home_max_hp)]

func _on_wave(idx: int) -> void:
    wave_label.text = "ウェーブ %d" % (idx + 1)
    wave_banner.text = "WAVE %d" % (idx + 1)
    wave_banner.modulate.a = 0.0
    var tw := create_tween()
    tw.tween_property(wave_banner, "modulate:a", 1.0, 0.25)
    tw.tween_interval(1.2)
    tw.tween_property(wave_banner, "modulate:a", 0.0, 0.6)

func _on_game_over() -> void:
    game_over.visible = true

func _process(_dt: float) -> void:
    var p := get_tree().current_scene.get_node_or_null("Player")
    if p == null or p.job_logic == null:
        return
    var cd_q: float = float(p.job_logic.cd.get("q", 0.0)) if "cd" in p.job_logic else 0.0
    var cd_e: float = float(p.job_logic.cd.get("e", 0.0)) if "cd" in p.job_logic else 0.0
    var cd_f: float = float(p.job_logic.cd.get("f", 0.0)) if "cd" in p.job_logic else 0.0
    skill_q.text = "[Q] %s" % ("準備中 %.1fs" % cd_q if cd_q > 0.0 else "発動可")
    skill_e.text = "[E] %s" % ("準備中 %.1fs" % cd_e if cd_e > 0.0 else "発動可")
    skill_f.text = "[F] %s" % ("準備中 %.1fs" % cd_f if cd_f > 0.0 else "発動可")
