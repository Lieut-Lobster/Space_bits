extends Node

@export var mob_scene: PackedScene
var score

# Called when the node enters the scene tree for the first time.
func _ready():
	_fix_the_shitty_glow_issue()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# So basically theres a really bad bug with glow and WorldEnironment
func _fix_the_shitty_glow_issue():
	for node in self.get_children():
		if node.name == "WorldEnvironment":
			continue
		if node.has_method("modulate"):
			if node.modulate == Color(1, 1, 1):
				node.modulate = Color(0.75, 0.75, 0.75)
