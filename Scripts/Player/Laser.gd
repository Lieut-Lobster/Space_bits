extends Area2D

#func _ready():
	#add_to_group("lasers")
	
func _process(delta):
	position.y -= 6
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	print("laser gone")
	queue_free()
