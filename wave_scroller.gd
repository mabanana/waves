extends Node2D
class_name Main

@export var sprite: Sprite2D
@export var exhaust_particle: GPUParticles2D


const _amplitude = 50.0
const _wave = 3.0
const _wave_length = 30.0
const _speed_limit = 8.0
const _unit = 100.0
var _acceleration = 1.0

var x_seed:= randf()+0.5
var y_seed:= randf()+0.5

var progress = 1
var speed = 0
var amplitude = _amplitude
var wave_length = _wave_length
var speed_limit = _speed_limit
var acceleration = _acceleration
var frequency:
	get():
		return speed / wave_length

var accelerating = false

var labels = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for property in ["progress", "speed", "amplitude", "wave_length", "speed_limit", "accelerating","acceleration", "frequency"]:
		var label = Label.new()
		var value = snapped(get(property), 0.01) if property != "accelerating" else get(property)
		label.text = "%s: %s" % [property, str(value)]
		$CanvasLayer/VBoxContainer.add_child(label)
		labels[property] = label
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var msec = Time.get_ticks_msec() * 0.0001
	progress += speed*delta
	sprite.position.y = sin(progress / wave_length * y_seed) * amplitude
	sprite.offset.y = sin(msec * x_seed * speed) * _wave
	sprite.position.x = sin(progress / wave_length * x_seed) * amplitude
	sprite.offset.x = sin(msec * y_seed * speed) * _wave
	wave_length = _wave_length * progress / (_unit + progress) + _wave_length
	amplitude = _amplitude * (progress) / (_unit + progress) + _wave
	speed_limit = _speed_limit + (progress / _unit)
	acceleration = _acceleration + (progress / _unit / _speed_limit) * _acceleration
	
	if accelerating:
		speed += acceleration * delta
		var dest_scale = Vector2.ONE * (1.0 - speed / speed_limit * 0.4)
		sprite.scale = dest_scale
		sprite.scale = Vector2(clamp(sprite.scale.x, 0.9, 1), clamp(sprite.scale.y, 0.9, 1))
		speed = clamp(speed, 0, speed_limit)
	else:
		speed = move_toward(speed, 0.0, _speed_limit * speed / speed_limit * delta)
		sprite.scale = sprite.scale.move_toward(Vector2.ONE, delta / _unit)
	
	for property in labels.keys():
		var value = snapped(get(property), 0.01) if property != "accelerating" else get(property)
		labels[property].text = "%s: %s" % [property, str(value)]

func _input(event):
	if event.is_action_pressed("accelerate"):
		accelerating = true
		exhaust_particle.amount_ratio = 1.0
	elif event.is_action_released("accelerate"):
		accelerating = false
		exhaust_particle.amount_ratio = 0.3
