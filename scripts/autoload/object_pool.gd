extends Node
# Lightweight object pool. Reuses scenes to avoid frame hitches on heavy waves.

var _pools: Dictionary = {}

func acquire(scene: PackedScene) -> Node:
    var key := scene.resource_path
    var bucket: Array = _pools.get(key, [])
    var inst: Node
    if bucket.is_empty():
        inst = scene.instantiate()
    else:
        inst = bucket.pop_back()
    return inst

func release(scene: PackedScene, inst: Node) -> void:
    if inst.get_parent():
        inst.get_parent().remove_child(inst)
    var key := scene.resource_path
    if not _pools.has(key):
        _pools[key] = []
    _pools[key].append(inst)
