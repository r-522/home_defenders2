extends Control

@onready var vsync_chk: CheckBox = $Panel/VBox/Graphics/VSync
@onready var fps_opt: OptionButton = $Panel/VBox/Graphics/FPSCap
@onready var bloom_chk: CheckBox = $Panel/VBox/Graphics/Bloom
@onready var ssao_chk: CheckBox = $Panel/VBox/Graphics/SSAO
@onready var master_slider: HSlider = $Panel/VBox/Audio/Master
@onready var bgm_slider: HSlider = $Panel/VBox/Audio/BGM
@onready var se_slider: HSlider = $Panel/VBox/Audio/SE
@onready var back_btn: Button = $Panel/VBox/Bottom/Back
@onready var save_btn: Button = $Panel/VBox/Bottom/Save

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    vsync_chk.button_pressed = bool(SettingsManager.graphics.vsync)
    bloom_chk.button_pressed = bool(SettingsManager.graphics.bloom)
    ssao_chk.button_pressed = bool(SettingsManager.graphics.ssao)
    for v in [30, 60, 120, 0]:
        fps_opt.add_item("FPS %s" % (str(v) if v > 0 else "無制限"))
    master_slider.value = float(SettingsManager.audio.master)
    bgm_slider.value = float(SettingsManager.audio.bgm)
    se_slider.value = float(SettingsManager.audio.se)
    save_btn.pressed.connect(_on_save)
    back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Title.tscn"))

func _on_save() -> void:
    SettingsManager.graphics.vsync = vsync_chk.button_pressed
    SettingsManager.graphics.bloom = bloom_chk.button_pressed
    SettingsManager.graphics.ssao = ssao_chk.button_pressed
    var caps := [30, 60, 120, 0]
    SettingsManager.graphics.fps_cap = caps[max(0, fps_opt.selected)]
    SettingsManager.audio.master = master_slider.value
    SettingsManager.audio.bgm = bgm_slider.value
    SettingsManager.audio.se = se_slider.value
    SettingsManager.save_all()
    SettingsManager.apply_all()
