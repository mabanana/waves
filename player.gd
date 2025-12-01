extends Node2D
class_name Player

signal damage_taken

@export var enemy_spawner: EnemySpawner
@export var music_controller: MusicController
@export var positions: Array[Marker2D]
@export var camera: Camera2D
@export var wave_scene: WaveScene
@onready var camera3: Camera3D = wave_scene.camera

var curr = 2
var speed := 3.0
var momentum := 0.0
var dir = 0
var l = false
var r = false

@onready var fov = camera3.fov

func _ready():
	position = positions[2].position
	enemy_spawner.enemy_tween_finished.connect(_on_enemy_tween_finished)
	damage_taken.connect($"../Damage".play)
	music_controller.beat_started.connect(func(beat):
		if $"../GameManager".game_started:
			start_camera_shake(0.075))

func _input(event):	
	if event.is_action_pressed("left"):
		l = true
	elif event.is_action_released("left"):
		l = false
	if event.is_action_pressed("right"):
		r = true
	elif event.is_action_released("right"):
		r = false
	
	if l and not r:
		dir = -1
	elif r and not l:
		dir = 1
	else: 
		dir = 0
		momentum = 0
	
func _process(delta):
	momentum += abs(dir)
	position.x += dir * (speed + momentum)
	position.x = clamp(position.x, positions[0].position.x, positions[-1].position.x)
	rotation = lerp(
		positions[-1].rotation,
		positions[0].rotation, 
		1 - (position.x - positions[0].position.x)/(positions[-1].position.x - positions[0].position.x))
	position.y = lerp(
		positions[-1].position.y,
		positions[2].position.y, 
		1 - abs(position.x - positions[2].position.x)/(positions[-1].position.x - positions[2].position.x))

func _on_enemy_tween_finished(marker_index):
	var player_indexes = []
	var min_dist = 70
	for i in range(len(positions)):
		var marker = positions[i]
		var dist = abs(position.x - marker.position.x)
		if dist < min_dist:
			player_indexes.append(i)
	if marker_index in player_indexes:
		damage_taken.emit()
		start_camera_shake(1.0)

func start_camera_shake(time: float):
	var camera_tween = get_tree().create_tween()
	camera_tween.tween_method(_camera_shake, 10.0*time, 0.2, time)
	return camera_tween.finished
func _camera_shake(intensity: float):
	var noise := FastNoiseLite.new()
	var camera_offset = noise.get_noise_1d(Time.get_ticks_msec()) * intensity
	camera.offset.x = camera_offset * randi_range(-1,1)
	camera.offset.y = camera_offset * randi_range(-1,1)
	camera3.h_offset = camera_offset * randi_range(-1,1)
	camera3.v_offset = camera_offset * randi_range(-1,1)
	
