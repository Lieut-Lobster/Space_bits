extends Node2D

var preloadedEnemies := [
	preload("res://Space_bits/Scenes/Enemy/Boss/Boss_01/Boss_01.tscn"),
	preload("res://Space_bits/Scenes/Enemy/mobs/Rammer/Enemy_Rammer.tscn"),
	preload("res://Space_bits/Scenes/Enemy/mobs/Sniper/enemy_sniper.tscn")
]

@onready var spawnTimer := $SpawnTimer

var nextSpawnTime := 0.001

# pixels per chunck, each chunk that they will be able to exist on is either 32 or 64 pixels x/y
var tile_size_gl := 64
var tile_size_midpoint_gl := 32


# NOTE: The grid of the projected play area is 150 chunks in total (64px, 64px) based.
# Grid sizing for the Enemies to spawn on (64px x 10 wide && 64px x 6 deep)

# Grid sizing for the World (64px x 10 wide && 64px x 15 deep)
var world_grid_size_x_gl := 10
var world_grid_size_y_gl := 15
# Global arrays to store the grids in
var spawn_grid := []
var world_grid := []
var events_grid := []

#Create level variable to be used for the adjust_spawn function
var level_name := "Level1"

func adjust_spawn_logic_based_on_level(level_name: String):
	match level_name:
		"Level1":
			var enemy_grid_size_x_gl := 10
			var enemy_grid_size_y_gl := 2
			spawn_grid = create_grid(tile_size_gl, tile_size_midpoint_gl, enemy_grid_size_x_gl, enemy_grid_size_y_gl)
		"Level2":
			var enemy_grid_size_x_gl := 10
			var enemy_grid_size_y_gl := 6
		_:
			# Default case if level name doesn't match
			print("Unknown level: " + level_name)

# _ready() calls before the frame of the game is being loaded.
func _ready():
	randomize()
	# print("Enemy Grid Array:")
	#Call function to adjust the spawn grid size for the level
	adjust_spawn_logic_based_on_level(level_name)
	# print("World Grid Array:")
	world_grid = create_grid(tile_size_gl, tile_size_midpoint_gl, world_grid_size_x_gl, world_grid_size_y_gl)
	# print("Events Grid Array:")
	events_grid = create_events_grid(world_grid, spawn_grid)
	spawnTimer.start(nextSpawnTime)
	
	
func _process(delta):
	pass
	#print(Global.player_pos)

# _on_spawn_timer_timeout() is a timer being signaled (Inherited from GridSpawn)
func _on_spawn_timer_timeout():
	# Spawn an enemy
	if spawn_grid.size() != 0:
		var enemyPreload = preloadedEnemies[randi() % preloadedEnemies.size()]
		var enemy = enemyPreload.instantiate()
		enemy.position = Vector2(spawn_grid[0][0], spawn_grid[0][1])
		spawn_grid.pop_front()
		get_tree().current_scene.add_child(enemy)
		enemy = lerp(enemy.position.x, 32.0, 1)
	# Restart the timer
	spawnTimer.start(nextSpawnTime)

# Creates a grid and stores it into an array
func create_grid(tile_size, tile_size_midpoint, grid_size_x, grid_size_y) -> Array:
	var create_grid: Array
	for placement_x in grid_size_x:
		for placement_y in grid_size_y:
			create_grid.append([tile_size * (placement_x + 1), tile_size * (placement_y + 1)])
	# print(create_grid)
	return create_grid

# array1 is used as the base array, and subtracts array2 from array1 (C = B - A)
func create_events_grid(array1, array2) -> Array:
	var events_grid := []
	for value in array1:
		if not (value in array2):
			events_grid.append(value)
	# print(events_grid)
	return events_grid
	
