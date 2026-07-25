extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Door

@export var is_active: = true

func _process(delta: float) -> void:
	if is_active:
		set_collision_layer_value(1, true)
		sprite.frame = 0
	else:
		set_collision_layer_value(1, false)
		sprite.frame = 1
