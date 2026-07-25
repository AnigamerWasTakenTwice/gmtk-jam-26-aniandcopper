extends ColorRect

@onready var player: CharacterBody2D = $".."

const WIND_SPEED = 250
const WIND_DIRECTION = Vector2(1, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player.global_position += delta * WIND_SPEED * WIND_DIRECTION
