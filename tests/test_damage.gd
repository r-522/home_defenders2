extends "res://addons/gut/test.gd"
# Sample GUT tests. Run via:
#   godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests

func test_tower_cost_lookup():
    var d = DataLoader.towers.get("arrow", {})
    assert_eq(int(d.get("cost", 0)), 50, "Arrow tower cost should match data")

func test_gold_spend():
    GameState.gold = 100
    assert_true(GameState.spend_gold(40))
    assert_eq(GameState.gold, 60)
    assert_false(GameState.spend_gold(999))
    assert_eq(GameState.gold, 60)

func test_home_damage():
    GameState.home_max_hp = 100.0
    GameState.home_hp = 100.0
    GameState.is_running = true
    GameState.damage_home(30.0)
    assert_eq(GameState.home_hp, 70.0)

func test_all_40_jobs_loaded():
    assert_eq(DataLoader.jobs.size(), 40, "Should have 40 jobs in jobs.json")
