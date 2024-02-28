extends Area2D

@onready var AnimatedPupil = $AnimatedSpritePupil
@onready var CenterOfEyeMarker = $CenterOfEye

@onready var ChargingAttackParticles = $AnimatedSpritePupil/CPUParticlesChargingAttack

@onready var ChargingBeamTimer = $ChargingBeam
var charging_beam_time := 2.0
@onready var FullyChargedTimer = $FullyCharged
var fully_charge_time = 5.0
@onready var DeathBeamFireTimer = $DeathBeamFiring
var beam_fire_time := 1.0
var beam_fire_duration := 0
@onready var BeamCoolingDownTimer = $BeamCoolingDown
var beam_cooling_time := 10.0
@onready var PupilToBaseStateTimer = $PupilBaseState
var pupil_to_base_time := 2.0

@export var is_death_beam_activated := false

var BossMode = BossMechanics.Boss02.new()

var is_charging_beam_timer_started := false

var pupil_speed = 0.8

var animation_index_pupil := 0
var animation_array_pupil := [
	"PupilDefault",
	"PupilCharging",
	"PupilDeathBeam",
	"PupilCoolingDown"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Player.player_pos != null:
		if is_death_beam_activated == true:
			move_pupil_to_center(delta)
			if is_charging_beam_timer_started == false:
				is_charging_beam_timer_started = true
				ChargingBeamTimer.start(charging_beam_time)
		else:
			move_pupil_to_follow_player(delta)
		
		anim_play(animation_index_pupil)
		AnimatedPupil.position = AnimatedPupil.position.clamp(Vector2(-4,-10), Vector2(4,10))

# MECHANICS FUNCTIONS

func move_pupil_to_follow_player(delta):
	if (Player.player_pos.x < CenterOfEyeMarker.global_position.x):
		AnimatedPupil.global_position.x += (Player.player_pos.x - AnimatedPupil.global_position.x) * (delta * pupil_speed)
	elif (Player.player_pos.x > CenterOfEyeMarker.global_position.x):
		AnimatedPupil.global_position.x += (Player.player_pos.x - AnimatedPupil.global_position.x) * (delta * pupil_speed)

func move_pupil_to_center(delta):
	var x = lerp(AnimatedPupil.global_position.x, CenterOfEyeMarker.global_position.x, 1)
	var y = lerp(AnimatedPupil.global_position.y, CenterOfEyeMarker.global_position.y, 1)
	AnimatedPupil.global_position += Vector2(x - AnimatedPupil.global_position.x,
											 y - AnimatedPupil.global_position.y) * (delta * pupil_speed)

func anim_play(anim_index : int):
	AnimatedPupil.play(animation_array_pupil[anim_index])

# SIGNALS

# The handling of keeping the animation to the ending position when charging / cooling-down
func _on_animated_sprite_pupil_animation_finished():
	if animation_array_pupil[animation_index_pupil] == "PupilCharging":
		AnimatedPupil.frame = 7
	if animation_array_pupil[animation_index_pupil] == "PupilCoolingDown":
		AnimatedPupil.frame = 7

func _on_charging_beam_timeout():
	animation_index_pupil = 1
	ChargingAttackParticles.emitting = true
	FullyChargedTimer.start(fully_charge_time)

func _on_fully_charged_timeout():
	ChargingAttackParticles.emitting = false
	DeathBeamFireTimer.start(beam_fire_time)

func _on_death_beam_firing_timeout():
	animation_index_pupil = 2
	BeamCoolingDownTimer.start(beam_cooling_time)

func _on_beam_cooling_down_timeout():
	animation_index_pupil = 3
	PupilToBaseStateTimer.start(pupil_to_base_time)

func _on_pupil_base_state_timeout():
	animation_index_pupil = 0
	is_death_beam_activated = false
	is_charging_beam_timer_started = false
