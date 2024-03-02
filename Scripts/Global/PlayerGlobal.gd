extends Node

var player_pos 

# Base-Stats (un-altered) of Player, will be adjusted with upgrades
var player_hp := 100
var player_shield := 50
var player_stamina := 100


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func player_position(in_player_pos):
	player_pos = in_player_pos

func player_take_damage(damage, enemy_type):
	print("------------ START PLAYER STAT LOGS ------------")
	print("Damage Taken From:        ", enemy_type)
	if player_shield != 0:
		# Testing out an idea that damage done to the shield maybe should be higher
		player_shield -= (damage * 2)
		print("Shield Damage Taken:      ", damage * 2)
		if player_shield <= 0:
			player_shield = 0
	elif player_hp > 0:
		print("Health Damage Taken:      ", damage)
		player_hp -= damage
		if player_hp <= 0:
			player_hp = 0
	print("Players Current Shield:   ", player_shield)
	print("Players Current HP:       ", player_hp)
	print("------------- END PLAYER STAT LOGS -------------")

func player_stamina_regen(stamina_regen_rate):
	if player_stamina <= 100:
		player_stamina += stamina_regen_rate
	else:
		player_stamina = 100
