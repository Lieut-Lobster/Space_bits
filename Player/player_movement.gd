extends Area2D 
signal hit

@export var speed = 200
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	position = Vector2(352, 800)
	#hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO
	Global.player_position(position)
	# Note: Game development is a little weird for the Y axis, Positive Y == Down && Negative Y == Up
	# This is for displaying the animation changes
	if velocity.x == 0 && velocity.y == 0:
		$AnimatedSprite2D.animation = "Standard_visuals"
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		$AnimatedSprite2D.animation = "Move_right"
	elif Input.is_action_pressed("move_left"):
		velocity.x -= 1
		$AnimatedSprite2D.animation = "Move_left"
	elif Input.is_action_pressed("move_down"):
		velocity.y += 1
		$AnimatedSprite2D.animation = "Move_down"
	elif Input.is_action_pressed("move_up"):
		velocity.y -= 1
		$AnimatedSprite2D.animation = "Move_up" 
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.play()
	# Movement for Player's ship
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	

func _on_body_entered(body):
	#hide() # Test, will make Player disappears after being hit
	#hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
