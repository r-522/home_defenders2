extends Node3D

@onready var spawner: Node3D = $EnemySpawner

func _ready() -> void:
    GameState.reset()
    # NavigationRegion bakes synchronously on _ready in Godot 4.3 via call_deferred.
    var nav: NavigationRegion3D = $NavigationRegion3D
    nav.bake_navigation_mesh(true)
    await get_tree().create_timer(0.5).timeout
    spawner.start_next_wave()
