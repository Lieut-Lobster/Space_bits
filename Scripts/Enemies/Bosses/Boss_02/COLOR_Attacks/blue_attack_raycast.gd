extends RayCast2D

@onready var casting_particles: GPUParticles2D = $BeamCastingParticles
@onready var collision_particles: GPUParticles2D = $CollisionParticles
@onready var beam_particle_2d: GPUParticles2D = $BeamParticles

var base_rotation_speed: float = 1
var rotation_speed_adjust : float = 0.8

# This is a raycast, so you can take a lot of damage quickly due to it's updating on collision
var damage := 6
var enemy_type := "Boss_02 - Blue Attack"

var is_casting: bool = false :
	set(value):
		is_casting = value
		
		beam_particle_2d.emitting = is_casting
		casting_particles.emitting = is_casting
		
		if is_casting:
			appear()
		else:
			collision_particles.emitting = false
			disapear()
		set_physics_process(is_casting)

func _ready():
	is_casting = false
	BossMechanics.blue_beam_casting(is_casting)

func _process(delta):
	is_casting = BossMechanics.is_beam_casting

#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#self.is_casting = event.pressed

func _physics_process(delta: float) -> void:
	var cast_point := target_position
	force_raycast_update()
	
	collision_particles.emitting = is_colliding()
	
	if is_colliding():
		var colliding_with = get_collider()
		if colliding_with.name == "Player":
			cast_point = to_local(get_collision_point())
			collision_particles.global_rotation = get_collision_normal().angle()
			collision_particles.position = cast_point
			if Player.player_pos != null:
				Player.player_take_damage(damage, enemy_type)
	
	$Line2D.points[1] = cast_point
	beam_particle_2d.position = cast_point * 0.5
	beam_particle_2d.process_material.emission_box_extents.x = cast_point.length() * 0.5
	
func appear() -> void:
	var tween = create_tween()
	tween.tween_property($Line2D, "width", 16.0, 0.5)

func disapear() -> void:
	var tween = create_tween()
	tween.tween_property($Line2D, "width", 0, 0.2)
