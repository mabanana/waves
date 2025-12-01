extends Node
class_name GameManager

@export var enemy_spawner: EnemySpawner
@export var main: Main
@export var music_controller: MusicController

var wave_num
var score

func start_game():
	wave_num = 0
	score = 0
