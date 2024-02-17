extends Area2D

@onready var EnemyBullet := $AnimatedSniperShot
@onready var DeleteBulletTimer := $DeleteBulletLater
var DeleteBulletDuration := 0.5

@export var bulletSpeed := 600

var velocity : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	EnemyBullet.play("BulletAnim")
	rotate(Game.enemy_3_deg_for_bullet)
	velocity = Vector2(0, bulletSpeed).rotated(Game.enemy_3_deg_for_bullet - 1.5707963268)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Player.player_pos != null:
		position += velocity * delta
		

func _on_visible_on_screen_notifier_2d_screen_exited():
	DeleteBulletTimer.start(DeleteBulletDuration)


func _on_delete_bullet_later_timeout():
	queue_free()
