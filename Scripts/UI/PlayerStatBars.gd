extends Control

@onready var player_health_bar = $Health2DSprite/HealthProgressBar
@onready var player_shield_bar = $Shield2DSprite/ShieldProgressBar
@onready var player_stamina_bar = $Stamina2DSprite/StaminaProgressBar
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player_shield_bar.value = Player.player_shield
	player_health_bar.value = Player.player_hp
	player_stamina_bar.value = Player.player_stamina
