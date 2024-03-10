extends Node2D

var _attack_angle_to_player : float
var is_beam_casting : bool

class Boss02:
	var _attack_dictionary : Dictionary
	var _is_death_beaming : bool
	
	func PupilDeathBeam(death_beam_state : bool):
		_is_death_beaming = death_beam_state

func AngleToPlayer(attack_angle : float):
	_attack_angle_to_player = attack_angle

func blue_beam_casting(is_casting : bool):
	is_beam_casting = is_casting
