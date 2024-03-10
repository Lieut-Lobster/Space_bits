extends RigidBody2D

@onready var attackTimer := $AttackPlayerTimer
var nextSpawnTime := 2
@onready var stallToAttackTimer := $StallThenAttackTimer
var stallTime := randi_range(1,2)
@onready var destroyEnemyObject := $BlowUpThenDestroyEnemy
var destroyEnemyTime := 1

var is_dead := false
var is_blowing_up := false

var enemy_hp := 10
var damage := 15
var enemy_type := "Enemy_02 - Rammer"

@onready var velocity = Vector2.ZERO

var is_targeting_player := true
var get_player_pos_x := 0.0
var get_player_pos_y := 0.0

var rand_attack_counter := randi_range(10, 60)
var moving := false
var attacking := false
var random_position_engage_attack = randi_range(512, 700)
var player_rammed := false
var velocity_change := 2

var animation_index := 0
var animation_array := [
	"idle",
	"Moving_Off_Spawn_Grid",
	"Moving_Off_Grid_Charged",
	"Start_Attack",
	"End_Attack",
	"On_Death"
]

func _ready():
	$AnimatedSprite2D.play(animation_array[animation_index])
	attackTimer.start(nextSpawnTime)
	# Rotate number assoicated here is very close to 90 degrees in radians
	rotate(1.5707963268)

func _physics_process(delta):
	if is_dead == false:
		change_attack_animation()
		if attacking == true:
			if is_targeting_player == true:
				is_targeting_player = false
				stallToAttackTimer.start(stallTime)
			if (
				(position.x <= get_player_pos_x + 20 && position.x >= get_player_pos_x - 20) &&
				(position.y <= get_player_pos_y + 20 && position.y >= get_player_pos_y - 20) &&
				player_rammed == true
			):
				animation_index = 5
				if is_blowing_up == true:
					is_blowing_up = false
					suicide()
			# Fix look_at() later, gotta be slower to turn to the player
			if Player.player_pos != null:
				look_at(Player.player_pos)
			move_and_collide(Vector2(get_player_pos_x - position.x, get_player_pos_y - position.y) * (delta * velocity_change))
			
		elif moving == true:
			move_and_collide(Vector2(0,64) * (delta * velocity_change))
		
		$AnimatedSprite2D.play(animation_array[animation_index])


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func change_attack_animation():
	
	if roundi(position.y) >= random_position_engage_attack + 50 && attacking == true:
		# Change animation to be ending cycle of attack (End_Attack)
		animation_index = 4
		
	elif roundi(position.y) >= random_position_engage_attack && attacking == false:
		# Change animation to be starting cycle of attack (Start_Attack)
		attacking = true
		velocity_change = 0
		animation_index = 3
		
	elif roundi(position.y) >= 512 && position.x >= 0 && attacking == false:
		animation_index = 2


func _on_attack_player_timer_timeout():
	# Counter for enemy to move off grid
	if rand_attack_counter >= 60 && moving == false:
		moving = true
		animation_index = 1
	else:
		rand_attack_counter += 1


func _on_stall_then_attack_timer_timeout():
	# After being stalled, increase velocity of Enemy
	velocity_change = 3
	get_player_pos_x = Player.player_pos.x
	get_player_pos_y = Player.player_pos.y
	player_rammed = true
	is_blowing_up = true

func _on_blow_up_then_destroy_enemy_timeout():
	queue_free()


func _on_player_collision_body_entered(body):
	if body.name == "Player":
		Player.player_take_damage(damage, enemy_type)

func suicide():
	destroyEnemyObject.start(destroyEnemyTime)
	
func killed():
	is_dead = true
	$LaserCollision.queue_free()
	$PlayerCollision.queue_free()
	animation_index = 5
	$AnimatedSprite2D.play(animation_array[animation_index])
	destroyEnemyObject.start(1)
	#queue_free()
	
func _on_laser_collision_area_entered(area):
	if area.is_in_group("lasers"):
		enemy_hp -= 3
		area.queue_free()
		$AnimatedSprite2D.self_modulate = Color.RED
		await get_tree().create_timer(0.15).timeout
		$AnimatedSprite2D.self_modulate = Color.WHITE
		if enemy_hp <= 0:
			killed()
