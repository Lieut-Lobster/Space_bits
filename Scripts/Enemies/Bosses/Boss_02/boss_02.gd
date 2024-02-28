extends RigidBody2D

var random = RandomNumberGenerator.new()

@onready var BodyAnimated2D = $AnimatedSpriteBody
@onready var RedTentacleAnim = $AnimatedSpriteBody/RedTentacle
@onready var RedTentacleTrail = $AnimatedSpriteBody/RedTentacle/CPUParticlesTrail
@onready var RedAttackIndicator = $AnimatedSpriteBody/RedTentacle/CPUParticlesIndicator

@onready var EyeLidAnimated2D = $AnimatedSpriteEye/AnimatedSpriteEyelid
@onready var EyeLidAnimTimer = $AnimatedSpriteEye/AnimatedSpriteEyelid/EyelidAnimTimer
var eyelid_anim_time := randi_range(2, 4)

@onready var screen_size_x = get_viewport_rect().size.x

var movement_speed_x := 0.4
var movement_speed_y := 0.1
var is_boss_moving := true

@onready var AttackTimer = $AttackTimer
var attack_time := 2

var attack_dictionary : Dictionary = {}
var random_attack_select : int
var attack_weighting_red := 0.0
var attack_weighting_blue := 0.0
var attack_weighting_green := 0.0
var is_attacking := false

const RedAttackScene = preload("res://Space_bits/Scenes/Enemy/Boss/Boss_02/Boss_attacks/red_attack.tscn")
@onready var RedAttackMarker = $AnimatedSpriteBody/RedMarker2D


var body_animation_index := 0
var body_animation_array := [
	"Default",
	"AttackRed",
	"AttackBlue",
	"AttackGreen"
]
var red_tentacle_animation_index := 0
var red_tentacle_animation_array := [
	"Right-to-Left",
	"Left-to-Right",
	"AttackStart",
	"AttackFinish"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	_fix_the_shitty_glow_issue()
	position = Vector2((screen_size_x / 2), 125)
	EyeLidAnimated2D.play("Default")
	BodyAnimated2D.play("Default")
	RedTentacleAnim.play(red_tentacle_animation_array[red_tentacle_animation_index])
	EyeLidAnimTimer.start(eyelid_anim_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Player.player_pos != null:
		boss_attack_weighting()
		if RedTentacleAnim.animation == "AttackStart":
			RedAttackIndicator.emitting = true
		if RedAttackIndicator.emitting == true:
			RedAttackIndicator.angle_min += 2
		else:
			RedAttackIndicator.angle_min = 0
			RedAttackIndicator.angle_max = 0
	boss_static_movement(delta, is_boss_moving, 0.2, 0.05)
	RedTentacleAnim.play(red_tentacle_animation_array[red_tentacle_animation_index])
	
	

# MECHANICS MECHANICS ---------------- MECHANICS MECHANICS

func boss_static_movement(delta : float, is_moving : bool, adjust_x_speed : float, adjust_y_speed : float):
	if is_moving:
		if position.x >= screen_size_x - 180.0:
			movement_speed_x -= adjust_x_speed * (delta * 2)
		if position.x <= 180.0:
			movement_speed_x += adjust_x_speed * (delta * 2)
		if position.y >= 140:
			movement_speed_y -= adjust_y_speed * (delta * 2)
		if position.y <= 110:
			movement_speed_y += adjust_y_speed * (delta * 2)
		position += Vector2(movement_speed_x, movement_speed_y)

func boss_attack_weighting():
	if !is_attacking:
		if (attack_weighting_red + attack_weighting_blue + attack_weighting_green) >= 3.0:
			red_tentacle_animation_index = 2
			is_attacking = true
			boss_attack_randomly_chosen()
		elif Player.player_pos.x >= screen_size_x * 0.6:
			attack_weighting_red += 0.003
			body_animation_index = 1
		elif Player.player_pos.x <= screen_size_x * 0.6 && Player.player_pos.x >= screen_size_x * 0.4:
			attack_weighting_blue += 0.003
			body_animation_index = 2
		elif Player.player_pos.x <= screen_size_x * 0.4:
			attack_weighting_green += 0.003
			body_animation_index = 3
	BodyAnimated2D.play(body_animation_array[body_animation_index])

func boss_attack_randomly_chosen():
	var weighted_red = snappedf(attack_weighting_red, 0.1) * 10
	var weighted_blue = snappedf(attack_weighting_blue, 0.1) * 10
	var weighted_green = snappedf(attack_weighting_green, 0.1) * 10
	var sum_weights : int = (weighted_red + weighted_blue + weighted_green)
	if attack_dictionary.is_empty():
		for key in sum_weights:
			if key + 1 <= weighted_red:
				attack_dictionary[key + 1] = "RED"
			elif key + 1 <= weighted_blue + weighted_red:
				attack_dictionary[key + 1] = "BLUE"
			elif key + 1 <= sum_weights:
				attack_dictionary[key + 1] = "GREEN"
	
	if !attack_dictionary.is_empty():
		random_attack_select = random.randi_range(1, attack_dictionary.size())
		print("--- Attack Style chosen is: ", attack_dictionary[random_attack_select], "\n")
		play_attack_chosen(attack_dictionary[random_attack_select])
	else:
		print("There was an error, attack_dictionary was never populated. This should never happen.")

func play_attack_chosen(attack_selected : String):
	BossMechanics.AngleToPlayer(RedAttackMarker.global_position.angle_to_point(Player.player_pos))
	if attack_selected == "RED":
		if RedTentacleAnim.animation_finished:
			red_tentacle_animation_index = 3
			RedTentacleTrail.emitting = true
			attack_instantiate_and_position(RedAttackScene, RedAttackMarker, attack_selected)
	if attack_selected == "BLUE":
		pass
	if attack_selected == "GREEN":
		pass
	reset_attacks()
	
func attack_instantiate_and_position(preloaded_scene : PackedScene, attack_marker : Marker2D, group_name : String):
	var attack = preloaded_scene.instantiate()
	attack.add_to_group(group_name)
	get_parent().add_child(attack)
	attack.global_position = attack_marker.global_position

func reset_attacks():
	attack_weighting_red = 0.0
	attack_weighting_blue = 0.0
	attack_weighting_green = 0.0
	attack_dictionary.clear()
	is_attacking = false

# TIMERS TIMERS ---------------------------- SIGNALS SIGNALS

# ATTACK STALLING (ANIMATION USAGE)
func _on_attack_staller_timeout():
	pass # Replace with function body.

# ATTACK TIMER HANDLING
func _on_attack_timer_timeout():
	pass

# EYELID ANIMATION HANDLING
func _on_eyelid_anim_timer_timeout():
	eyelid_anim_time = random.randi_range(4, 8)
	EyeLidAnimated2D.play("EyelidClose")
	EyeLidAnimTimer.start(eyelid_anim_time)

func _on_animated_sprite_eyelid_animation_finished():
	if EyeLidAnimated2D.animation == "EyelidClose":
		EyeLidAnimated2D.play("EyelidOpen")
	elif EyeLidAnimated2D.animation == "EyelidOpen":
		EyeLidAnimated2D.play("Default")

# RED-TENTACLE ANIMATION HANDLING
func _on_red_tentacle_animation_finished():
	
	if !is_attacking:
		if RedTentacleAnim.animation == "Right-to-Left":
			red_tentacle_animation_index = 1
		elif RedTentacleAnim.animation == "Left-to-Right":
			red_tentacle_animation_index = 0
	if RedTentacleAnim.animation == "Left-to-Right":
			red_tentacle_animation_index = 2
	if RedTentacleAnim.animation == "AttackStart":
		red_tentacle_animation_index = 3
	if RedTentacleAnim.animation == "AttackFinish":
		red_tentacle_animation_index = 1
		


# GODOT BUG FIX IMPLEMENTATION -------- NOTHING ELSE BELOW
# So basically theres a really bad bug with glow and WorldEnironment
# Since this Bug exists, ultimately what I am doing here is crawl through child nodes - 
#	- and adjust the COLOR modulation to be 0.85 to avoid the glow effect
func _fix_the_shitty_glow_issue():
	for node in self.get_children():
		#print(node.name)
		if node.name == "DeathBeam2D":
			continue
		if node.name == "AttackTimer":
			continue
		if node.name == "AttackStaller":
			continue
		if node.modulate == Color(1, 1, 1):
			node.modulate = Color(0.85, 0.85, 0.85)








