extends RigidBody2D

@onready var ChargeAttackSprite2D := $AnimatedSprite2D

@onready var StallUntilAttack := $StalledUntilAttackTimer
var stall_attack_time := 0.1

var attack_indicate := false

var wait_to_attack := randi_range(0,10)
var attack_initiative := 15

var start_charging_attack := false

var animation_index := 0
var animation_array := [
	"Idle",
	"Charge_Attack",
	"Attack_Notifier"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play(animation_array[animation_index])
	rotate(1.5707963268)
	StallUntilAttack.start(stall_attack_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	change_attack_animation()
	look_at(Player.player_pos)
	#print(ChargeAttackSprite2D.frame)
	$AnimatedSprite2D.play(animation_array[animation_index])
	if ChargeAttackSprite2D.frame == 19:
		ChargeAttackSprite2D.frame = 19
		
	
func change_attack_animation():
	#print(start_charging_attack)
	if start_charging_attack == true:
		animation_index = 1


func _on_stalled_until_attack_timeout():
	if wait_to_attack < attack_initiative:
		wait_to_attack += 1
	else:
		start_charging_attack = true


func _on_animated_sprite_2d_animation_finished():
	print("Gay Butt Cheeks")
