extends CharacterBody2D

#For lasers
@onready var LaserCooldown := $LaserCooldown
@export var new_laser_time := 0.6
const laserPath = preload('res://Space_bits/Scenes/Player/Laser.tscn')

# Every <stamina_regen_time> seconds, regen <stamina_regen_rate> until 100 stamina
# Example: It will take with current settings, 5 seconds to reach full stamina 
@onready var StaminaRegenTimer := $StaminaRegenTimer
@export var stamina_regen_time := 0.1
@export var stamina_regen_rate := 1

@onready var IFramesTimer := $InvincibilityFramesTimer
var i_frames_time := 1.0

var player_hp : float

@export var player_speed = 200
@onready var screen_size_x = get_viewport_rect().size.x

# |********** Player Upgrades / Abilities Chosen **********|
var barrel_roll_ability_active : bool = true
var barrel_roll_stamina_usage_amount : float = 100
# |********************************************************|

var player_animation_index := 0
var player_animation_array := [
	"Idle", "move_down",
	"move_down_left", "move_down_right",
	"move_left", "move_right",
	"move_up", "move_up_left",
	"move_up_right",
]

func _ready():
	player_hp = Player.player_hp
	position = Vector2((screen_size_x / 2), 808)
	StaminaRegenTimer.start(stamina_regen_time)

func _process(delta):
	Player.player_position(position)
	$AnimatedSprite2D.play(player_animation_array[player_animation_index])
	if player_hp > Player.player_hp:
		player_hp = Player.player_hp
		$AnimatedSprite2D.self_modulate = Color.RED
		await get_tree().create_timer(0.35).timeout
		$AnimatedSprite2D.self_modulate = Color.WHITE
	
	if Input.is_action_pressed("space_bar") and LaserCooldown.is_stopped():
		LaserCooldown.start(new_laser_time)
		shoot()
	
	if Input.is_action_pressed("shift"):
		if Player.player_stamina == 100:
			if barrel_roll_ability_active == true:
				collision_layer = 2
				Player.player_stamina_used(barrel_roll_stamina_usage_amount)
				IFramesTimer.start(i_frames_time)
			# This currently does nothing except makes the animation restart
			# Will need some type of functionality for this which no idea what yet.
	

func _physics_process(delta):
	# Remove 'elif' and replace with if if you want to move diagnaly, for now only quad movement
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x = 1
	elif Input.is_action_pressed("move_left"):
		velocity.x = -1
	elif Input.is_action_pressed("move_down"):
		velocity.y = 1
	elif Input.is_action_pressed("move_up"):
		velocity.y = -1
	
	animation_handler(velocity.normalized())
	if velocity.length() > 0:
		var calculated_movement : Vector2 = velocity.normalized() * (player_speed * delta)
		position += calculated_movement
	position = position.clamp(Vector2.ZERO, Vector2(screen_size_x, 872))

func animation_handler(_velocity : Vector2):
	if _velocity.length() == 1:
		if _velocity.x == 1:
			player_animation_index = 5
		if _velocity.x == -1:
			player_animation_index = 4
		if _velocity.y == 1:
			player_animation_index = 1
		if _velocity.y == -1:
			player_animation_index = 6
	elif _velocity.length() > 1:
		# Does not enter right now, if you want diagonal movement, read comment above about the elif(s)
		pass
	else:
		player_animation_index = 0

func _on_body_entered(body):
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionPolygon2D.set_deferred("disabled", true)

func shoot():
	var laser = laserPath.instantiate()
	laser.add_to_group("lasers")
	get_parent().add_child(laser)
	laser.position = $Marker2D.global_position

func _on_stamina_regen_timer_timeout():
	Player.player_stamina_regen(stamina_regen_rate)
	StaminaRegenTimer.start(stamina_regen_time)

func _on_invincibility_frames_timer_timeout():
	collision_layer = 1
