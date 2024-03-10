extends Area2D

@onready var RedAttackAnim = $AnimatedSprite2D 
@onready var RedAttackTrail = $AnimatedSprite2D/CPUParticles2D

var speed := 380
var velocity : Vector2

var damage := 15
var enemy_type = "Boss_02 - RED Attack"


# Called when the node enters the scene tree for the first time.
func _ready():
	RedAttackAnim.play("Default")
	rotate(BossMechanics._attack_angle_to_player)
	RedAttackTrail.angle_max = -rad_to_deg(BossMechanics._attack_angle_to_player)
	RedAttackTrail.angle_min = -rad_to_deg(BossMechanics._attack_angle_to_player)
	velocity = Vector2(0, speed).rotated(BossMechanics._attack_angle_to_player - 1.5707963268)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Player.player_pos != null:
		position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_body_entered(body):
	if body.name == "Player":
		Player.player_take_damage(damage, enemy_type)
