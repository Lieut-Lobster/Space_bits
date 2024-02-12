extends Node


#use users if releasing to people res is global
const SAVE_PATH = "res://savegame.bin"

func saveGame():
	#Create temp file to write inside to save
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	#Create dictionary for saves JSON format
	var data: Dictionary = {
		"playerHP": Game.playerHP,
		"playerShield": Game.playerShield,
		"score": Game.score
	}
	var jstr = JSON.stringify(data)
	file.store_line(jstr)
	
func loadGame():
	#Read saved file
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	#Check if file exists
	if FileAccess.file_exists(SAVE_PATH) == true:
		#If we didnt reach the end of the file
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				Game.playerHP = current_line["playerHP"]
				Game.playerShield = current_line["playerShield"]
				Game.score = current_line["score"]
	
