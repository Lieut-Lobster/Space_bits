extends Node2D

var preloadedEnemies := [
	preload("res://Space_bits/Scenes/Enemy/Boss/Boss_01.tscn"),
	preload("res://Space_bits/Scenes/Enemy/mobs/Enemy_Rammer.tscn")
]

@onready var spawnTimer := $SpawnTimer

var nextSpawnTime := 0.001

# pixels per chunck, each chunk that they will be able to exist on is either 32 or 64 pixels x/y
var tile_size_gl := 64
var tile_size_midpoint_gl := 32

# setting a default size for the grid (60 being 10 chunks wide and 6 chunks deep)
var grid_size_x_gl := 10
var grid_size_y_gl := 6
var grid := []

func _ready():
	randomize()
	grid = create_spawn_grid(tile_size_gl, tile_size_midpoint_gl, grid_size_x_gl, grid_size_y_gl)
	spawnTimer.start(nextSpawnTime)
	

func _on_spawn_timer_timeout():
	# Spawn an enemy
	if grid.size() != 0:
		var enemyPreload = preloadedEnemies[randi() % preloadedEnemies.size()]
		var enemy = enemyPreload.instantiate()
		enemy.position = Vector2(grid[0][0], grid[0][1])
		grid.pop_front()
		get_tree().current_scene.add_child(enemy)
	
	#Restart the timer
	spawnTimer.start(nextSpawnTime)

func create_spawn_grid(tile_size, tile_size_midpoint, grid_size_x, grid_size_y) -> Array:
	var create_grid: Array
	for placement_x in grid_size_x:
		for placement_y in grid_size_y:
			create_grid.append([tile_size * (placement_x + 1), tile_size * (placement_y + 1)])
	print(create_grid)
	return create_grid
