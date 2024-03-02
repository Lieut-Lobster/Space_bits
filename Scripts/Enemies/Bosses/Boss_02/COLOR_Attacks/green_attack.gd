extends Area2D

@onready var AnimTree : AnimationTree = $AnimationTree
@onready var saw_edges : Sprite2D = $SpriteCircularEdges

@onready var InnerCircleCollider : CollisionShape2D = $CollisionShape2D
@onready var ExplosionRingCollider : Node2D = $RingCollision

var explosion_ring_scene = preload("res://Space_bits/Scenes/Custom/ring_collision.tscn")

# speed in this case, 1 = normal speed, speed < 1 == slower, speed > 1 == faster
var speed := 0.8
var velocity : Vector2

var damage := 10
var enemy_type := "Boss_02 - Green Attack (Pre-Explosion)"

var players_last_position : Vector2

var is_saw_blade_shrinking : bool = false
var has_explosion_ended : bool = false



var explosion_collider

# Called when the node enters the scene tree for the first time.
func _ready():
	if Player.player_pos != null:
		players_last_position = Player.player_pos
	rotate(BossMechanics._attack_angle_to_player)
	AnimTree["parameters/conditions/destination_not_reached"] = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	AnimationTreeHandling()
	if Player.player_pos != null:
		position += Vector2(0, (players_last_position.y - position.y) * delta * speed).rotated(BossMechanics._attack_angle_to_player - 1.5707963268)
	if saw_edges != null:
		saw_edges.rotation_degrees -= 2
		if is_saw_blade_shrinking == true:
			saw_edges.scale -= Vector2(0.016, 0.016)
			if saw_edges.scale <= Vector2(2.2, 2.2):
				saw_edges.queue_free()
	if explosion_collider != null && has_explosion_ended == false:
		explosion_collider.scale += Vector2(0.022, 0.022)
		scale += Vector2(0.04, 0.04)

func AnimationTreeHandling():
	if ((position.y < players_last_position.y + 20 && position.y > players_last_position.y - 20) &&
		(position.x < players_last_position.x + 20 && position.x > players_last_position.x - 20)
	):
		AnimTree["parameters/conditions/destination_not_reached"] = false
		AnimTree["parameters/conditions/has_reached_destination"] = true

func instantiate_explosion_ring_collider():
	explosion_collider = explosion_ring_scene.instantiate()
	explosion_collider.add_to_group("Explosion")
	get_parent().add_child(explosion_collider)
	explosion_collider.global_position = players_last_position

func _on_body_entered(body):
	if body.name == "Player":
		Player.player_take_damage(damage, enemy_type)

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "PrepExplosion":
		InnerCircleCollider.queue_free()
		instantiate_explosion_ring_collider()
	if anim_name == "Explosion":
		has_explosion_ended = true
		explosion_collider.queue_free()
	if anim_name == "DissipateExplosion":
		queue_free()

func _on_animation_tree_animation_started(anim_name):
	if anim_name == "PrepExplosion":
		is_saw_blade_shrinking = true

