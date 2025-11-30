extends MeshInstance3D
var material: ShaderMaterial
var balls: Array[Vector3]
var radi: Array[float]
@export var num_balls = 3
@export var volatility := 3.0
@export var ang_speed := 0.5
@export var rotate: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	material = mesh.material
	for i in range(num_balls):
		var new_ball := Vector3(randf(),randf(),randf()) * volatility
		balls.append(new_ball)
		radi.append(randf() / 5000.0)
	rotate = Vector3(randf(),randf(),randf()).normalized()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var new_radi: Array[int] = []
	for i in range(len(balls)):
		balls[i] = balls[i].rotated(rotate, ang_speed)
		new_radi.append(radi[i] * sin(Time.get_ticks_msec() / 1000))
	#print(balls)
	material.set_shader_parameter("ball_pos", PackedVector3Array(balls))
	material.set_shader_parameter("radi", radi)
	pass
