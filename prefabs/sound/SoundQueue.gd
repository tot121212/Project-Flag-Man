@tool
extends Node2D
class_name SoundQueue

# Plays sounds and truncates the amount depending on count, i.e. if count == 4, and the amount that are playing is 4, the one that was played before all others that are currently playing, will be stopped and play a new sound.

@export var count : int = 4
@export var pitch_variance : float = 0.2

var _audio_stream_players : Array[AudioStreamPlayer2D]

func _ready():
	if len(get_children()) != 1:
		push_warning("Incorrect amount of children on SoundQueue, please use only one")
		return
		
	var child = get_child(0)
	if child is AudioStreamPlayer2D:
		#copy that node into the array instance_count amt of times
		for i in range(count):
			var new_player = child.duplicate()
			add_child(new_player)
			_audio_stream_players.append(new_player)
	

func play_sound():
	var max_player: AudioStreamPlayer2D = null
	for player in _audio_stream_players:
		if not player.playing:
			max_player = player
			break
		elif max_player == null or max_player.get_playback_position() < player.get_playback_position(): 
			max_player = player
			
	if max_player != null:
		var tmp = max_player.pitch_scale
		max_player.pitch_scale = max_player.pitch_scale + randf_range(-pitch_variance, +pitch_variance)
		max_player.play()
		await max_player.finished
		max_player.pitch_scale = tmp
