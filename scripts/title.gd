extends Control

@onready var job_list: ItemList = $Panel/VBox/HBox/JobList
@onready var info_label: Label = $Panel/VBox/HBox/JobInfo
@onready var start_btn: Button = $Panel/VBox/Buttons/Start
@onready var settings_btn: Button = $Panel/VBox/Buttons/Settings
@onready var room_edit: LineEdit = $Panel/VBox/Buttons/Room

var ids: Array = []

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    ids = JobRegistry.all_ids()
    ids.sort()
    for id in ids:
        var d: Dictionary = JobRegistry.get_job(id)
        job_list.add_item("%s (%s)" % [d.get("name", id), d.get("category", "?")])
    if ids.size() > 0:
        job_list.select(0)
        _update_info(0)
    job_list.item_selected.connect(_update_info)
    start_btn.pressed.connect(_on_start)
    settings_btn.pressed.connect(_on_settings)

func _update_info(idx: int) -> void:
    var id: String = ids[idx]
    var d: Dictionary = JobRegistry.get_job(id)
    info_label.text = "%s\nCategory: %s\nHP: %d\nATK: %d\nAtkCD: %.2fs" % [
        d.get("name", id), d.get("category", "?"),
        int(d.get("hp", 0)), int(d.get("atk", 0)),
        float(d.get("attack_cd", 0.5))
    ]

func _on_start() -> void:
    var sel := job_list.get_selected_items()
    if sel.size() > 0:
        GameState.selected_job_id = ids[sel[0]]
    var rid := room_edit.text.strip_edges()
    if rid != "":
        # Network is opt-in; only host if user typed a room.
        NetworkManager.host_room(rid)
    get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_settings() -> void:
    get_tree().change_scene_to_file("res://scenes/Settings.tscn")
