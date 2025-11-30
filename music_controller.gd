extends Node
class_name MusicController
@export var main_loop: AudioStreamPlayer
const main_track := preload("res://wave.ogg")

# when progress is at end, go to start time
var loop_windows = [[0,32], [10, 14], [18, 22], [26, 30]] # [end, start]
var loop = 0
var label: Label

func _ready():
	var bar_length = main_track.loop_offset
	# go_to_bar(main_loop, 30)
	label = Label.new()
	$"../CanvasLayer/VBoxContainer".add_child(label)

func _process(delta):
	var loop_time = bar_to_time(main_loop, loop_windows[loop][1])
	var current_bar = time_to_bar(main_loop, main_loop.get_playback_position())
	if main_loop.playing and current_bar == loop_time:
		go_to_bar(main_loop, loop_windows[loop][0])
	label.text = "Loop bar: %s" % loop_windows[loop][1]

func time_to_bar(stream_player: AudioStreamPlayer, seconds: float):
	var stream = stream_player.stream
	if stream == null:
		push_warning("No stream assigned to player.")
		return

	var bpm = stream.get_bpm()
	var beats_per_bar = stream.get_bar_beats()
	var total_beats = stream.get_beat_count()
	var total_bars = int(total_beats / beats_per_bar)
	var bar_duration = (beats_per_bar / bpm) * 60.0 # convert minutes to seconds
	var length = stream.get_length()
	
	if seconds < 0 or seconds >= length:
		push_warning("time %d out of range (0–%d)" % [seconds, length])
		return

	var target_bar = floori(seconds / bar_duration)
	# clamp to stream length
	target_bar = clamp(target_bar, 0.0, total_bars)
	
	return target_bar

func bar_to_time(stream_player: AudioStreamPlayer, bar_index: int):
	var stream = stream_player.stream
	if stream == null:
		push_warning("No stream assigned to player.")
		return

	var bpm = stream.get_bpm()
	var beats_per_bar = stream.get_bar_beats()
	var total_beats = stream.get_beat_count()
	var total_bars = int(total_beats / beats_per_bar)
	var bar_duration = (beats_per_bar / bpm) * 60.0 # convert minutes to seconds
	
	if bar_index == total_bars:
		return stream.get_length()
	elif bar_index < 0 or bar_index >= total_bars:
		push_warning("Bar index %d out of range (0–%d)" % [bar_index, total_bars - 1])
		return

	var target_time = bar_index * bar_duration
	# clamp to stream length
	target_time = clamp(target_time, 0.0, stream.get_length())
	
	return target_time

func go_to_bar(stream_player: AudioStreamPlayer, bar_index: int) -> void:
	var target_time = bar_to_time(stream_player, bar_index)

	# move playback to target position
	stream_player.stop()
	stream_player.play(target_time)

func go_to_loop(index: int):
	loop += 1
	if 0 > loop or loop >= len(loop_windows):
		loop = 0

func _input(event):
	if event.is_action_pressed("ui_right"):
		go_to_loop(loop+1)
