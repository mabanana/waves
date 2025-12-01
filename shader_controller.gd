extends Node
class_name ShaderController
@export var main: Main
@export var wave_scene: Node3D
@export var music_controller: MusicController
var wave_mesh: MeshInstance3D
var wave_material: ShaderMaterial

var slide_speed
var wobble_speed
var wobble_intensity
var texture_scale
var wave_height
var curvature
var texture
var time_scale
var bpm

func _ready():
	for child in wave_scene.get_children():
		if child is MeshInstance3D and child.mesh.material is ShaderMaterial:
			wave_material = child.mesh.material
			wave_mesh = child

func _process(delta):
	var bpm = music_controller.main_loop.stream.get_bpm()
	wave_height = clamp(1.0 + main.amplitude / main._unit / 20, 1, 2.25)
	wobble_speed = clamp(bpm/60 + main.amplitude / main._unit, 1.5, 5.5)
	wobble_intensity = clamp(0.8 + main.amplitude / main._unit / 17, 0.8, 2.1)
	slide_speed = clamp(0.35 + main.frequency / main._unit / 7, 0.35, 1.0)
	#wave_material.set_shader_parameter("wave_height", wave_height)
	wave_material.set_shader_parameter("wobble_speed", wobble_speed)
	#wave_material.set_shader_parameter("wobble_intensity", wobble_intensity)
	#wave_material.set_shader_parameter("slide_speed", slide_speed)
	wave_material.set_shader_parameter("bpm", bpm)
	wave_material.set_shader_parameter("progress", main.progress)
