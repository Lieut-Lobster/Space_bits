extends Node2D

func _ready():
	Utils.saveGame()
	Utils.loadGame()
	pass

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Space_bits/Scenes/Levels/level_1.tscn")


func _on_quit_pressed():
	get_tree().quit() 
