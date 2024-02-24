extends Node2D

class Boss02:
	var _attack_dictionary : Dictionary
	var _is_death_beaming : bool
	
	func PupilDeathBeam(death_beam_state : bool):
		_is_death_beaming = death_beam_state
	
