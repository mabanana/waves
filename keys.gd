extends Sprite2D
@export var key_code: Key

func _input(event):
	if event is InputEventKey and event.keycode == key_code:
		if event.is_pressed():
			scale = Vector2.ONE * 4
		else:
			scale = Vector2.ONE * 2
	
