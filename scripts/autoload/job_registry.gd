extends Node
# 職業 ID から、データ定義と専用スキルスクリプトを解決する。

# 専用スキルロジックを持つ職業。未登録の職は _stub.gd（共通 AOE）にフォールバック。
const SPECIALISED := {
    "fighter":    "res://scripts/jobs/fighter.gd",
    "mage":       "res://scripts/jobs/mage.gd",
    "cleric":     "res://scripts/jobs/cleric.gd",
    "archer":     "res://scripts/jobs/archer.gd",
    "machinist":  "res://scripts/jobs/machinist.gd",
}

func get_job(id: String) -> Dictionary:
    var jobs = DataLoader.jobs
    if not jobs.has(id):
        push_warning("未知の職業 ID: %s" % id)
        return {}
    return jobs[id]

func all_ids() -> Array:
    return DataLoader.jobs.keys()

func make_skill_handler(id: String, owner: Node) -> Node:
    # 職業固有のスキル処理ノードを生成し、プレイヤーの子として登録する。
    var script_path: String = SPECIALISED.get(id, "res://scripts/jobs/_stub.gd")
    if not ResourceLoader.exists(script_path):
        script_path = "res://scripts/jobs/_stub.gd"
    var node := Node.new()
    node.set_script(load(script_path))
    node.name = "JobLogic_%s" % id
    owner.add_child(node)
    if node.has_method("init"):
        node.init(owner)
    return node
