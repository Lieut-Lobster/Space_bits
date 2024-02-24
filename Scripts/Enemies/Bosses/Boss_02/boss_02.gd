extends RigidBody2D

@onready var AnimatedBody = $AnimatedSpriteBody
@onready var AnimatedEye = $AnimatedSpriteBody/AnimatedSpriteEye
@onready var AnimatedPupil = $AnimatedSpriteBody/AnimatedSpriteEye/PupilCollision/AnimatedSpritePupil
@onready var MarkerForPupil = $AnimatedSpriteBody/AnimatedSpriteEye/PupilCollision/EyeLeavingCollision
@onready var BoundingBoxOfEye = $AnimatedSpriteBody/AnimatedSpriteEye/PupilCollision/EyeBoundingWallsCollision

@onready var screen_size_x = get_viewport_rect().size.x

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2((screen_size_x / 2), 195)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Player.player_pos != null:
		pass
			
