@tool
extends Node2D
class_name SoundPool

# Plays a random sfx between a group of SoundQueue's

var _sounds : Array[SoundQueue]
var _random : RandomNumberGenerator
var _last_index : int = -1

func _ready():
	for child in get_children():
		if child is SoundQueue:
			_sounds.append(child)
			
func play_random_sound():
	var index : int 
	while true:
		index = _random.randi_range(0, len(_sounds) - 1)
		if index != _last_index:
			break
	
	_last_index = index
	_sounds[index].play_sound()
