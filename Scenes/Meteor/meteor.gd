extends Area2D

@export var minSpeed: float = 10
@export var maxSpeed: float = 20
@export var minRotationRate: float = -25
@export var maxRotationRate: float = 25

var speed: float = 0
var rotationRate: float = 0

func _ready():
	speed = randf_range(minSpeed, maxSpeed)
	rotationRate = randf_range(minRotationRate, maxRotationRate)
	
func _physics_process(delta):
	rotation_degrees += rotationRate * delta
	
	position.y += speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
