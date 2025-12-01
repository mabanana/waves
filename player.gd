extends Node2D

signal damage_taken

@export var enemy_spawner: EnemySpawner
@export var positions: Array[Marker2D]

var curr = 2
var speed := 3.0
var momentum := 0.0
var dir = 0
var l = false
var r = false

func _ready():
	position = positions[2].position
	enemy_spawner.enemy_tween_finished.connect(_on_enemy_tween_finished)
	

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
		print("You've been hit")
