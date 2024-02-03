extends Node2D

var preloadedEnemies := [
	preload("res://Space_bits/Scenes/mob.tscn")
]

@onready var spawnTimer := $SpawnTimer

var nextSpawnTime := 5

var grid := []

func _ready():
	randomize()
	grid = create_spawn_grid(64, 32, 10)
	spawnTimer.start(nextSpawnTime)

func _on_spawn_timer_timeout():
	# Spawn an enemy
	if grid.size() != 0:
		var enemyPreload = preloadedEnemies[randi() % preloadedEnemies.size()]
		var enemy = enemyPreload.instantiate()
		enemy.position = Vector2(grid[0], 200)
		grid.pop_front()
		get_tree().current_scene.add_child(enemy)
	
	#Restart the timer
	spawnTimer.start(nextSpawnTime)

func create_spawn_grid(tile_size, tile_size_midpoint, grid_size):
	var create_grid: Array
	for placement in grid_size:
		create_grid.append(tile_size * (placement + 1))
	print(create_grid)
	return create_grid
