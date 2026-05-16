extends Node
# 軽量オブジェクトプール。多数の敵・弾を使い回し、フレーム落ちを抑える。

var _pools: Dictionary = {}

func acquire(scene: PackedScene) -> Node:
    # プールに在庫があれば再利用、無ければ新規生成。
    var key := scene.resource_path
    var bucket: Array = _pools.get(key, [])
    var inst: Node
    if bucket.is_empty():
        inst = scene.instantiate()
    else:
        inst = bucket.pop_back()
    return inst

func release(scene: PackedScene, inst: Node) -> void:
    # ノードを親ツリーから外して在庫へ戻す。
    if inst.get_parent():
        inst.get_parent().remove_child(inst)
    var key := scene.resource_path
    if not _pools.has(key):
        _pools[key] = []
    _pools[key].append(inst)
