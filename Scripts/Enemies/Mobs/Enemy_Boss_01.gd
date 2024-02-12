extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play("Boss_Idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# so basically, just code the boss 4head
	pass


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
