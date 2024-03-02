extends Area2D

@onready var EnemyBullet := $AnimatedSniperShot

var speed := 600
var velocity : Vector2

var damage := 10
var enemy_type := "Enemy_03 - Sniper Shot"

# Called when the node enters the scene tree for the first time.
func _ready():
	EnemyBullet.play("BulletAnim")
	rotate(Game.enemy_3_deg_for_bullet)
	velocity = Vector2(0, speed).rotated(Game.enemy_3_deg_for_bullet - 1.5707963268)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Player.player_pos != null:
		position += velocity * delta
		

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		Player.player_take_damage(damage, enemy_type)
