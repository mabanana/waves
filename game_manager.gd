extends Node
class_name GameManager

@export var enemy_spawner: EnemySpawner
@export var main: Main
@export var music_controller: MusicController
@export var shader_controller: ShaderController
@export var wave_label: Label

var wave_length = 10
var wave_num
var wave_countdown
var game_started = false
var between_duration = 8

func _ready():
	music_controller.bar_started.connect(func(bar_num):
		if bar_num == 4 and not game_started:
			game_started = true
			start_game()
		)

func start_game():
	wave_num = 1
	main.progress = 0
	next_wave()
	shader_controller.wave_material.set_shader_parameter("time_offset", Time.get_ticks_msec())
	
func next_wave():
	await between_waves()
	enemy_spawner.stop = false
	enemy_spawner.spawn_interval -= (enemy_spawner.spawn_interval - 0.1) * 0.25
	wave_length += wave_num
	enemy_spawner.spawn_enemy()
	get_tree().create_timer(wave_length).timeout.connect(func():
		enemy_spawner.stop = true
		wave_num += 1
		next_wave()
		)

func between_waves():
	wave_label.text = "Wave %s is about to begin" % [wave_num]
	if wave_num == 1:
		wave_label.text += "\n W to Accelerate, A D to Steer"
	wave_label.pivot_offset = wave_label.size / 2.0
	wave_label.show()
	var tween := get_tree().create_tween()
	tween.tween_method(tween_label, 0, between_duration * PI, between_duration)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.play()
	tween.finished.connect(wave_label.hide)
	return tween.finished

func tween_label(progress):
	wave_label.get_parent().position = Vector2(sin(progress / 2) * 2, sin(progress) * 4)
