extends RigidBody2D

var random = RandomNumberGenerator.new()

@onready var BodyAnimated2D = $AnimatedSpriteBody

@onready var AnimationTreeRED : AnimationTree = $AnimatedSpriteBody/RedTentacle/AnimationTreeRED
@onready var AnimationTreeGREEN : AnimationTree = $AnimatedSpriteBody/GreenTentacle/AnimationTreeGREEN

## RED TENTACLE IMPORTS
@onready var RedTentacleAnim = $AnimatedSpriteBody/RedTentacle
@onready var RedTentacleTrail = $AnimatedSpriteBody/RedTentacle/CPUParticlesTrail
@onready var RedAttackIndicator = $AnimatedSpriteBody/RedTentacle/CPUParticlesIndicator
## BLUE TENTACLE IMPORTS
## *************************************
## GREEN TENTACLE IMPORTS
@onready var GreenTentacleAnim = $AnimatedSpriteBody/GreenTentacle


@onready var EyeLidAnimated2D = $AnimatedSpriteEye/AnimatedSpriteEyelid
@onready var EyeLidAnimTimer = $AnimatedSpriteEye/AnimatedSpriteEyelid/EyelidAnimTimer
var eyelid_anim_time := randi_range(2, 4)

@onready var screen_size_x = get_viewport_rect().size.x

var movement_speed_x := 0.6
var movement_speed_y := 0.2
var is_boss_moving := true

var attack_dictionary : Dictionary = {}
var random_attack_select : int
var attack_weighting_red := 0.0
var attack_weighting_blue := 0.0
var attack_weighting_green := 0.0
var is_attacking := false

var attack_chosen_global : String

#Globals for the logic controller on animations for what attack style is being used.
var is_red_attack_selected := false
var is_blue_attack_selected := false
var is_green_attack_selected := false

const RedAttackScene = preload("res://Space_bits/Scenes/Enemy/Boss/Boss_02/Boss_attacks/Red_Attack/red_attack.tscn")
@onready var RedAttackMarker = $AnimatedSpriteBody/RedMarker2D

const GreenAttackScene = preload("res://Space_bits/Scenes/Enemy/Boss/Boss_02/Boss_attacks/Green_Attack/green_attack.tscn")
@onready var GreenAttackMarker = $AnimatedSpriteBody/GreenMarker2D

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
var green_tentacle_animation_index := 0
var green_tentacle_animation_array := [
	"Left-to-Right",
	"Right-to-Left"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	_fix_the_shitty_glow_issue()
	position = Vector2((screen_size_x / 2), 125)
	EyeLidAnimated2D.play("Default")
	BodyAnimated2D.play("Default")
	EyeLidAnimTimer.start(eyelid_anim_time)
	AnimationTreeRED.active = true
	AnimationTreeGREEN.active = true

func _process(_delta):
	if Player.player_pos != null:
		animation_tree_handling()
		boss_attack_weighting()
		if RedTentacleAnim.animation == "AttackStart":
			RedAttackIndicator.emitting = true
			RedAttackIndicator.angle_min += 2
		else:
			RedAttackIndicator.angle_min = 0
			RedAttackIndicator.angle_max = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	boss_static_movement(delta, is_boss_moving, 0.2, 0.05)
	
	

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
			print("Attack Weighting Complete!")
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
	is_attacking = true
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
		attack_chosen_global = attack_dictionary[random_attack_select]
		play_attack_chosen(attack_dictionary[random_attack_select])
	else:
		print("There was an error, attack_dictionary was never populated. This should never happen.")

func play_attack_chosen(attack_selected : String):
	if attack_selected == "RED":
		is_red_attack_selected = true
	if attack_selected == "BLUE":
		is_blue_attack_selected = true
		reset_attacks()
	if attack_selected == "GREEN":
		attack_instantiate_and_position(GreenAttackScene, GreenAttackMarker, "GREEN")
		reset_attacks()
		is_green_attack_selected = true

func attack_instantiate_and_position(preloaded_scene : PackedScene, attack_marker : Marker2D, group_name : String):
	var attack = preloaded_scene.instantiate()
	BossMechanics.AngleToPlayer(attack_marker.global_position.angle_to_point(Player.player_pos))
	attack.add_to_group(group_name)
	get_parent().add_child(attack)
	attack.global_position = attack_marker.global_position

func animation_tree_handling():
	if attack_chosen_global == "RED" && is_attacking:
		AnimationTreeRED["parameters/conditions/is_idle_red"] = false
		AnimationTreeRED["parameters/conditions/is_attack_red"] = is_red_attack_selected
	else:
		AnimationTreeRED["parameters/conditions/is_idle_red"] = true
		AnimationTreeRED["parameters/conditions/is_attack_red"] = false
	
	if attack_chosen_global == "GREEN" && is_attacking:
		AnimationTreeGREEN["parameters/conditions/is_idle_green"] = false
	else:
		AnimationTreeGREEN["parameters/conditions/is_idle_green"] = true

func reset_attacks():
	is_red_attack_selected = false
	is_blue_attack_selected = false
	is_green_attack_selected = false
	is_attacking = false
	attack_weighting_red = 0.0
	attack_weighting_blue = 0.0
	attack_weighting_green = 0.0
	attack_dictionary.clear()
	

# TIMERS TIMERS ---------------------------- SIGNALS SIGNALS

func _on_animation_tree_red_animation_finished(anim_name):
	print("Name of Anim finished: ", anim_name)
	if anim_name == "AttackStart-RED":
		RedTentacleTrail.emitting = true
		attack_instantiate_and_position(RedAttackScene, RedAttackMarker, "RED")
	if anim_name == "AttackFinish-RED":
		reset_attacks()
	

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




