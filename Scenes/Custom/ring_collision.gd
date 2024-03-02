extends Node2D

var damage := 20
var enemy_type := "Boss_02 - Green Attack (Explosion)"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		Player.player_take_damage(damage, enemy_type)
