extends CharacterBody2D
signal hit

#For lasers
@onready var LaserCooldown := $LaserCooldown
@export var new_laser_time := 0.3
const laserPath = preload('res://Space_bits/Scenes/Player/Laser.tscn')

# Every <stamina_regen_time> seconds, regen <stamina_regen_rate> until 100 stamina
# Example: It will take with current settings, 5 seconds to reach full stamina 
@onready var StaminaRegenTimer := $StaminaRegenTimer
@export var stamina_regen_time := 0.1
@export var stamina_regen_rate := 2

@export var player_speed = 200
@onready var screen_size_x = get_viewport_rect().size.x

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2((screen_size_x / 2), 808)
	StaminaRegenTimer.start(stamina_regen_time)
	#hide()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_accept") and LaserCooldown.is_stopped():
		LaserCooldown.start(new_laser_time)
		shoot()
		
	var velocity = Vector2.ZERO
	Player.player_position(position)
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
		velocity = velocity.normalized() * player_speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.play()
	# Movement for Player's ship
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, Vector2(704, 872))
	

func _on_body_entered(body):
	#hide() # Test, will make Player disappears after being hit
	#hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func shoot():
	print("Shoot!")
	var laser = laserPath.instantiate()
	laser.add_to_group("lasers")
	get_parent().add_child(laser)
	laser.position = $Marker2D.global_position

func _on_stamina_regen_timer_timeout():
	Player.player_stamina_regen(stamina_regen_rate)
	StaminaRegenTimer.start(stamina_regen_time)
