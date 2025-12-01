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
var total_waves = 6

func _ready():
	music_controller.bar_started.connect(func(bar_num):
		if bar_num == 4 and not game_started:
			game_started = true
			$"../NextWave".play()
			start_game()
		)
	music_controller.beat_started.connect(func(beat):
		if not game_started :
			if beat >= 12:
				wave_label.show()
				wave_label.text = str(16 - beat)
				$"../Player".start_camera_shake(0.2)
			elif beat >= 8:
				wave_label.show()
				wave_label.text = "and dodge the incoming hazards"
			elif beat >= 4:
				wave_label.show()
				wave_label.text = "Go as fast as you can"
		)

func start_game():
	wave_num = 1
	main.progress = 0
	main.speed = 0
	main.accelerating = true
	main.exhaust_particle.amount_ratio = 1.0
	next_wave()
	shader_controller.wave_material.set_shader_parameter("time_offset", Time.get_ticks_msec())
	
func next_wave():
	await between_waves()
	enemy_spawner.stop = false
	enemy_spawner.spawn_interval -= (enemy_spawner.spawn_interval - 0.1) * 0.4
	wave_length += wave_num
	enemy_spawner.spawn_enemy()
	get_tree().create_timer(wave_length).timeout.connect(func():
		enemy_spawner.stop = true
		wave_num += 1
		if wave_num == total_waves:
			wave_label.show()
			wave_label.text = "Thats all i got, thanks for playing"
			main.end_animation()
			await get_tree().create_timer(4).timeout
			get_tree().change_scene_to_file("res://wave_scroller.tscn")
			return
		next_wave()
		$"../NextWave".play()
		)

func between_waves():
	wave_label.text = "Wave %s/%s" % [wave_num, total_waves]
	if wave_num == 1:
		wave_label.text += "\n W to Accelerate, A D to Steer"
	elif wave_num == total_waves:
		wave_label.text = "Final Wave"
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
