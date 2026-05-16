extends Node
# Loads JSON data files. All balance numbers live in data/*.json.

var jobs: Dictionary = {}
var enemies: Dictionary = {}
var towers: Dictionary = {}
var waves: Array = []
var balance: Dictionary = {}

func _ready() -> void:
    jobs = _load_json("res://data/jobs.json")
    enemies = _load_json("res://data/enemies.json")
    towers = _load_json("res://data/towers.json")
    var w = _load_json("res://data/waves.json")
    waves = w.get("waves", []) if w is Dictionary else []
    balance = _load_json("res://data/balance.json")

func _load_json(path: String) -> Variant:
    if not FileAccess.file_exists(path):
        push_warning("Missing data file: %s" % path)
        return {}
    var f := FileAccess.open(path, FileAccess.READ)
    var txt := f.get_as_text()
    var parsed = JSON.parse_string(txt)
    if parsed == null:
        push_error("Failed to parse %s" % path)
        return {}
    return parsed
