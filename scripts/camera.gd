extends Camera2D

@export var decay: float = 0.8
@export var max_offset : Vector2 = Vector2(100, 75)
@export var max_roll: float = 0.0

var delfault_pos

var trauma : float = 0.0
var trauma_power : int = 2

var is_on_y : bool = true


func _process(delta: float) -> void:
	delfault_pos =  global_position
	
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func add_trauma(amount: float):
	trauma = min(trauma + amount, 1.0)

func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	if is_on_y: offset.y = max_offset.y * amount * randf_range(-1, 1)
