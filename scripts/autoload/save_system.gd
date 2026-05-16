extends Node
# user://save.json に保存。Web では Godot が user:// を IndexedDB へ自動でマップする。

const SAVE_PATH := "user://save.json"

var data: Dictionary = {
    "highest_wave": 0,
    "unlocked_jobs": ["fighter", "mage", "cleric", "archer", "machinist"],
    "stats": {},
}

func _ready() -> void:
    load_game()

func save_game() -> void:
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f == null:
        push_warning("セーブファイルを書き込めません")
        return
    f.store_string(JSON.stringify(data))

func load_game() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    var parsed = JSON.parse_string(f.get_as_text())
    if parsed is Dictionary:
        data.merge(parsed, true)

func unlock_job(id: String) -> void:
    if not data.unlocked_jobs.has(id):
        data.unlocked_jobs.append(id)
        save_game()

func record_wave(w: int) -> void:
    # 自己ベストのウェーブのみ更新。
    if w > int(data.get("highest_wave", 0)):
        data.highest_wave = w
        save_game()
