extends RigidBody2D

@onready var BodyAnimated2D := $AnimationParts/AnimatedSprite2DBody
@onready var TurretAnimated2D := $AnimationParts/AnimatedSprite2DTurret
@onready var BulletSpawnMarker := $AnimationParts/AnimatedSprite2DTurret/Bullet

@onready var destroyEnemyObject := $DestroyEnemyObject

@onready var StallUntilAttack := $StalledUntilAttackTimer
var stall_attack_time := 0.2

const bulletPath = preload('res://Space_bits/Scenes/Enemy/mobs/Sniper/Enemy_Sniper_Bullet/enemy_3_shot.tscn')
var deg_for_bullet : float

var start_charging_attack := false
var is_attack_charged := false
var is_attack_started := false
var is_attack_shot := false

var is_dead := false

var wait_to_attack := randi_range(0,10)
var attack_initiative := 15

var animation_index_body := 0
var animation_array_body := [
	"Body_Idle",
	"Body_Attack"
]
var animation_index_turret := 0
var animation_array_turret := [
	"Turret_Idle",
	"Charging_Turret_Attack",
	"Turret_Attack_Indicator",
	"Turret_Attack"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	#$AnimatedSprite2D.play(animation_array[animation_index])
	rotate(1.5707963268)
	StallUntilAttack.start(stall_attack_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_dead == false:
		change_attack_animation()
		BodyAnimated2D.play(animation_array_body[animation_index_body])
		TurretAnimated2D.play(animation_array_turret[animation_index_turret])
		if Player.player_pos != null:
			TurretAnimated2D.look_at(Player.player_pos)
		
func change_attack_animation():
	#print(start_charging_attack)
	if start_charging_attack == true:
		animation_index_turret = 1
		TurretAnimated2D.animation_finished
	if is_attack_charged == true:
		animation_index_turret = 2
		TurretAnimated2D.animation_finished
	if is_attack_started == true:
		animation_index_turret = 3
		TurretAnimated2D.animation_finished
	if is_attack_shot == true:
		# Attack animations will be reset
		enemy_3_shoot()
		animation_index_turret = 0
		start_charging_attack = false
		is_attack_charged = false
		is_attack_started = false
		is_attack_shot = false
		wait_to_attack = randi_range(0,10)
		StallUntilAttack.start(stall_attack_time)
	
func _on_animated_sprite_2d_turret_animation_finished():
	if animation_index_turret == 1:
		is_attack_charged = true
	elif animation_index_turret == 2:
		is_attack_started = true
	elif animation_index_turret == 3:
		is_attack_shot = true
	else:
		pass
	
func _on_stalled_until_attack_timeout():
	if wait_to_attack < attack_initiative:
		wait_to_attack += 1
	else:
		start_charging_attack = true

func _on_destroy_enemy_object_timeout():
	queue_free()

func enemy_3_shoot():
	print("Enemy 3 shot")
	Game.enemy_3_degrees_shot(BulletSpawnMarker.global_position.angle_to_point(Player.player_pos))
	print(Game.enemy_3_deg_for_bullet)
	var bullet = bulletPath.instantiate()
	bullet.add_to_group("bullets")
	get_parent().add_child(bullet)
	bullet.position = BulletSpawnMarker.global_position

func killed():
	print("I JUST GOT KILLED!")
	is_dead = true
	$PlayerAttackCollision.queue_free()
	animation_index_body = 1
	BodyAnimated2D.play(animation_array_body[animation_index_body])
	destroyEnemyObject.start(1)
	#queue_free()

func _on_player_attack_collision_area_entered(area):
	if area.is_in_group("lasers"):
		killed()
		area.queue_free()

