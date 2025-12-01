extends Node
class_name EnemySpawner

signal enemy_tween_finished

@onready var enemy_mesh := preload("res://enemy.tscn")

@export var main: Main
@export var wave_scene: WaveScene
var markers: Array[Marker3D]
var camera: Camera3D

var stop = false
var tween_duration := 4.0
var spawn_interval := 2.0

func _ready():
	markers = wave_scene.markers
	camera = wave_scene.camera

func spawn_enemy():
	if stop: return
	
	
	var marker_index = randi_range(0, len(markers) - 1)
	#print(marker_index)
	var marker = markers[marker_index]
	var marker_offset = marker.position - markers[2].position
	var new_enemy := enemy_mesh.instantiate()
	new_enemy.position = marker.position + Vector3.UP * 40
	wave_scene.add_child(new_enemy)
	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	
	var duration = clamp(tween_duration - main.speed / 10.0, 0.2, tween_duration)
	var interval = clamp(spawn_interval - float(main.progress / main._unit), 0.1, tween_duration)
	var tween_dest = camera.position + Vector3.DOWN*2
	tween_dest += (new_enemy.position - tween_dest).normalized() * 2.5
	
	tween.tween_property(new_enemy, "position", tween_dest, duration)
	tween.finished.connect(func():
		enemy_tween_finished.emit(marker_index)
		new_enemy.queue_free()
		)
	await get_tree().create_timer(interval).timeout
	spawn_enemy()
