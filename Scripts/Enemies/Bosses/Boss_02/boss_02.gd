extends RigidBody2D

var random = RandomNumberGenerator.new()

@onready var BodyAnimated2D = $AnimatedSpriteBody

@onready var AnimationTreeRED : AnimationTree = $AnimatedSpriteBody/RedTentacle/AnimationTreeRED
@onready var AnimationTreeGREEN : AnimationTree = $AnimatedSpriteBody/GreenTentacle/AnimationTreeGREEN
@onready var AnimationTreeBLUE : AnimationTree = $AnimatedSpriteBody/BlueTentacle/AnimationTreeBLUE

## RED TENTACLE IMPORTS
const RedAttackScene = preload("res://Space_bits/Scenes/Enemy/Boss/Boss_02/Boss_attacks/Red_Attack/red_attack.tscn")
@onready var RedAttackMarker = $AnimatedSpriteBody/RedMarker2D
@onready var RedTentacleAnim = $AnimatedSpriteBody/RedTentacle
@onready var RedTentacleTrail = $AnimatedSpriteBody/RedTentacle/CPUParticlesTrail
@onready var RedAttackIndicator = $AnimatedSpriteBody/RedTentacle/CPUParticlesIndicator
## BLUE TENTACLE IMPORTS
@onready var BlueRightAttackMarker = $BlueTentacleAttack/MarkerRight
@onready var BlueLeftAttackMarker = $BlueTentacleAttack/MarkerLeft
@onready var BlueTentacleAnim = $AnimatedSpriteBody/BlueTentacle
@onready var BlueTentacleRightTrail = $AnimatedSpriteBody/BlueTentacle/CPUParticlesTrailRight
@onready var BlueTentacleLeftTrail = $AnimatedSpriteBody/BlueTentacle/CPUParticlesTrailLeft
## GREEN TENTACLE IMPORTS
const GreenAttackScene = preload("res://Space_bits/Scenes/Enemy/Boss/Boss_02/Boss_attacks/Green_Attack/green_attack.tscn")
@onready var GreenAttackMarker = $AnimatedSpriteBody/GreenMarker2D
@onready var GreenTentacleAnim = $AnimatedSpriteBody/GreenTentacle
@onready var GreenTentacleOrbPulse = $AnimatedSpriteBody/GreenTentacle/OrbPulse
@onready var GreenTentacleAbsorbParticles = $AnimatedSpriteBody/GreenTentacle/AbsorbParticles
@onready var EyeLidAnimated2D = $AnimatedSpriteEye/AnimatedSpriteEyelid
@onready var EyeLidAnimTimer = $AnimatedSpriteEye/AnimatedSpriteEyelid/EyelidAnimTimer
var eyelid_anim_time := randi_range(2, 4)

@onready var screen_size_x = get_viewport_rect().size.x

var BOSS_HEALTH : float = 550.0

var movement_speed_x := 0.6
var movement_speed_y := 0.2
var is_boss_moving := true

#Base Chances are 33% of each style, the chances will adjust with where the player is located
const base_attack_chances_dictionary : Dictionary = {
	31: "RED", 32: "RED", 33: "RED", 34: "RED", 35: "RED", 36: "RED", 37: "RED", 38: "RED", 39: "RED", 40: "RED",
	41: "BLUE", 42: "BLUE", 43: "BLUE", 44: "BLUE", 45: "BLUE", 46: "BLUE", 47: "BLUE", 48: "BLUE", 49: "BLUE", 50: "BLUE",
	51: "GREEN", 52: "GREEN", 53: "GREEN", 54: "GREEN", 55: "GREEN", 56: "GREEN", 57: "GREEN", 58: "GREEN", 59: "GREEN", 60: "GREEN"
}
var attack_dictionary : Dictionary = {}
var random_attack_select : int
var attack_weighting_red := 0.0
var attack_weighting_blue := 0.0
var attack_weighting_green := 0.0
var is_attacking := false

#Globals for the logic controller on animations for what attack style is being used.
var is_red_attack_selected := false
var is_blue_attack_selected := false
var is_green_attack_selected := false

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
	boss_static_movement(delta, is_boss_moving, 1.0, 0.3)
	
	

# MECHANICS MECHANICS ---------------- MECHANICS MECHANICS

func boss_static_movement(delta : float, is_moving : bool, adjust_x_speed : float, adjust_y_speed : float):
	if is_moving:
		if position.x >= screen_size_x - 180.0:
			movement_speed_x -= adjust_x_speed * (delta * 2.5)
		if position.x <= 180.0:
			movement_speed_x += adjust_x_speed * (delta * 2.5)
		if position.y >= 140:
			movement_speed_y -= adjust_y_speed * (delta)
		if position.y <= 110:
			movement_speed_y += adjust_y_speed * (delta)
		position += Vector2(movement_speed_x, movement_speed_y)
	else:
		if movement_speed_x > 0:
			movement_speed_x = 0.6
		else:
			movement_speed_x = -0.6
		
		if movement_speed_y > 0:
			movement_speed_y = 0.2
		else:
			movement_speed_y = -0.2
		
		# This should only occur when BLUE Attack is chosen
		position += Vector2((screen_size_x/2) - position.x, 100 - position.y) * (delta * 2.5)
		if position > Vector2((screen_size_x/2) - 10, 90) && position < Vector2((screen_size_x/2) + 10, 110):
			is_blue_attack_selected = true
			if BlueTentacleAnim.animation == "Attack" && BlueTentacleAnim.frame != 0:
				BlueRightAttackMarker.rotate(1.55 * delta)
				BlueLeftAttackMarker.rotate(-1.55 * delta)
func boss_attack_weighting():
	if !is_attacking:
		if (attack_weighting_red + attack_weighting_blue + attack_weighting_green) >= 3.0:
			BlueRightAttackMarker.rotation_degrees = -90
			BlueLeftAttackMarker.rotation_degrees = 90
			BlueRightAttackMarker.position = Vector2(165, -144)
			BlueLeftAttackMarker.position = Vector2(165, 144)
			print("Attack Weighting Complete!")
			boss_attack_randomly_chosen()
		elif Player.player_pos.x >= screen_size_x * 0.6:
			attack_weighting_red += 0.004
			body_animation_index = 1
		elif Player.player_pos.x <= screen_size_x * 0.6 && Player.player_pos.x >= screen_size_x * 0.4:
			attack_weighting_blue += 0.004
			body_animation_index = 2
		elif Player.player_pos.x <= screen_size_x * 0.4:
			attack_weighting_green += 0.004
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
		attack_dictionary.merge(base_attack_chances_dictionary)
		random_attack_select = random.randi_range(1, attack_dictionary.size())
		print(attack_dictionary)
		play_attack_chosen(attack_dictionary[random_attack_select])
	else:
		print("There was an error, attack_dictionary was never populated. This should never happen.")

func play_attack_chosen(attack_selected : String):
	if attack_selected == "RED":
		is_red_attack_selected = true
	if attack_selected == "BLUE":
		is_boss_moving = false
	if attack_selected == "GREEN":
		is_green_attack_selected = true

func attack_instantiate_and_position(preloaded_scene : PackedScene, attack_marker : Marker2D, group_name : String):
	var attack = preloaded_scene.instantiate()
	BossMechanics.AngleToPlayer(attack_marker.global_position.angle_to_point(Player.player_pos))
	attack.add_to_group(group_name)
	get_parent().add_child(attack)
	attack.global_position = attack_marker.global_position

func animation_tree_handling():
	if is_red_attack_selected == true && is_attacking:
		AnimationTreeRED["parameters/conditions/is_idle_red"] = false
		AnimationTreeRED["parameters/conditions/is_attack_red"] = is_red_attack_selected
	else:
		AnimationTreeRED["parameters/conditions/is_idle_red"] = true
		AnimationTreeRED["parameters/conditions/is_attack_red"] = false
	
	if is_blue_attack_selected == true && is_attacking:
		AnimationTreeBLUE["parameters/conditions/is_idle_blue"] = false
		AnimationTreeBLUE["parameters/conditions/is_attack_blue"] = true
	else:
		AnimationTreeBLUE["parameters/conditions/is_idle_blue"] = true
		AnimationTreeBLUE["parameters/conditions/is_attack_blue"] = false
	
	if is_green_attack_selected == true && is_attacking:
		AnimationTreeGREEN["parameters/conditions/is_idle_green"] = false
		AnimationTreeGREEN["parameters/conditions/is_attack_green"] = true
	else:
		AnimationTreeGREEN["parameters/conditions/is_idle_green"] = true
		AnimationTreeGREEN["parameters/conditions/is_attack_green"] = false

func reset_attacks():
	is_boss_moving = true
	is_attacking = false
	is_red_attack_selected = false
	is_blue_attack_selected = false
	is_green_attack_selected = false
	attack_weighting_red = 0.0
	attack_weighting_blue = 0.0
	attack_weighting_green = 0.0
	attack_dictionary.clear()
	
# ******************************************************************
# --- TIMERS TIMERS ---------------------------- SIGNALS SIGNALS ---
# START --- RED ANIMATION / MECHANICS HANDLING --- START
func _on_animation_tree_red_animation_finished(anim_name):
	if anim_name == "AttackStart-RED":
		RedTentacleTrail.emitting = true
		attack_instantiate_and_position(RedAttackScene, RedAttackMarker, "RED")
	if anim_name == "AttackFinish-RED":
		reset_attacks()
# END ---- RED ANIMATION / MECHANICS HANDLING ---- END

# START -- BLUE ANIMATION / MECHANICS HANDLING -- START
func _on_animation_tree_blue_animation_finished(anim_name):
	match anim_name:
		"Attack-BLUE":
			reset_attacks()

func _on_blue_tentacle_frame_changed():
	if BlueTentacleAnim.animation == "Attack":
		match BlueTentacleAnim.frame:
			0:
				BlueTentacleRightTrail.emitting = true
				BlueTentacleLeftTrail.emitting = true
				BossMechanics.blue_beam_casting(true)
			1:
				BlueRightAttackMarker.position += Vector2(8, 0)
				BlueLeftAttackMarker.position += Vector2(8, 0)
			2:
				BlueRightAttackMarker.position += Vector2(8, 8)
				BlueLeftAttackMarker.position += Vector2(8, -8)
			3:
				BlueRightAttackMarker.position += Vector2(19, 15)
				BlueLeftAttackMarker.position += Vector2(19, -15)
			4:
				BlueRightAttackMarker.position += Vector2(12, 13)
				BlueLeftAttackMarker.position += Vector2(12, -13)
			5:
				BlueRightAttackMarker.position += Vector2(18, 11)
				BlueLeftAttackMarker.position += Vector2(18, -11)
			6:
				BlueRightAttackMarker.position += Vector2(18, 10)
				BlueLeftAttackMarker.position += Vector2(18, -10)
			7:
				BlueRightAttackMarker.position += Vector2(7, 18)
				BlueLeftAttackMarker.position += Vector2(7, -18)
			8:
				BlueRightAttackMarker.position += Vector2(0, 14)
				BlueLeftAttackMarker.position += Vector2(0, -14)
			9:
				BlueRightAttackMarker.position += Vector2(-7, 9)
				BlueLeftAttackMarker.position += Vector2(-7, -9)
			10:
				BlueRightAttackMarker.position += Vector2(-10, 15)
				BlueLeftAttackMarker.position += Vector2(-10, -15)
			11: 
				BossMechanics.blue_beam_casting(false)
# END ---- BLUE ANIMATION / MECHANICS HANDLING ---- END

# START -- GREEN ANIMATION / MECHANICS HANDLING -- START
func _on_animation_tree_green_animation_started(anim_name):
	match anim_name:
		"AttackStart-GREEN":
			GreenTentacleOrbPulse.emitting = true
			GreenTentacleAbsorbParticles.emitting = true
		"AttackFinish-GREEN":
			GreenTentacleOrbPulse.emitting = false
			GreenTentacleAbsorbParticles.emitting = false

func _on_animation_tree_green_animation_finished(anim_name):
	match anim_name:
		"AttackStart-GREEN":
			attack_instantiate_and_position(GreenAttackScene, GreenAttackMarker, "GREEN")
		"AttackFinish-GREEN":
			reset_attacks()
# END ---- GREEN ANIMATION / MECHANICS HANDLING ---- END

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

func _on_area_2d_area_entered(area):
	if area.is_in_group("lasers"):
		if BOSS_HEALTH > 0:
			BOSS_HEALTH -= 3
			area.queue_free()
			BodyAnimated2D.self_modulate = Color.RED
			await get_tree().create_timer(0.15).timeout
			BodyAnimated2D.self_modulate = Color.WHITE
		else:
			BodyAnimated2D.self_modulate = Color.BLACK
			BOSS_HEALTH = 0
			print("Boss_02 Got killed")
		print("Boss_02 HP: ",BOSS_HEALTH)
		
# ******************************************************************


# GODOT BUG FIX IMPLEMENTATION -------- NOTHING ELSE BELOW
# So basically theres a really bad bug with glow and WorldEnironment
# Since this Bug exists, ultimately what I am doing here is crawl through child nodes - 
#	- and adjust the COLOR modulation to be 0.85 to avoid the glow effect
func _fix_the_shitty_glow_issue():
	for node in self.get_children():
		#print(node.name)
		if node.name == "DeathBeam2D":
			continue
		if node.name == "AnimatedSpriteBody":
			continue
		if node.name == "BlueTentacleAttack":
			continue
		if node.modulate == Color(1, 1, 1):
			node.modulate = Color(0.85, 0.85, 0.85)

