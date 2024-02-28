extends Node

@export var mob_scene: PackedScene
var score

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	_fix_the_shitty_glow_issue()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()


func _on_mob_timer_timeout():
	pass
	#var mob = mob_scene.instantiate()
#
	## Choose a random location on Path2D.
	#var mob_spawn_location = $MobPath/MobSpawnLocation
	#mob_spawn_location.progress_ratio = randf()
#
	## Set the mob's direction perpendicular to the path direction.
	#var direction = mob_spawn_location.rotation + PI / 2
#
	## Set the mob's position to a random location.
	#mob.position = mob_spawn_location.position
#
	## Add some randomness to the direction.
	#direction += randf_range(-PI / 4, PI / 4)
	#mob.rotation = direction
#
	## Choose the velocity for the mob.
	#var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	#mob.linear_velocity = velocity.rotated(direction)
#
	## Spawn the mob by adding it to the Main scene.
	#add_child(mob)


func _on_score_timer_timeout():
	score += 1


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

# So basically theres a really bad bug with glow and WorldEnironment
func _fix_the_shitty_glow_issue():
	for node in self.get_children():
		if node.name == "WorldEnvironment":
			continue
		if node.has_method("modulate"):
			if node.modulate == Color(1, 1, 1):
				node.modulate = Color(0.75, 0.75, 0.75)
