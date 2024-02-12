extends Node



var player_hp
var player_pos 
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func player_position(in_player_pos):
	player_pos = in_player_pos

func player_health(in_player_hp):
	player_hp = in_player_hp
