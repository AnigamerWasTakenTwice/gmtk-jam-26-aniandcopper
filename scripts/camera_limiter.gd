extends Area2D

@export var top: int = -10000000
@export var bottom: int = 10000000
@export var left: int = -10000000
@export var right: int = 10000000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.camera_bottom_threshhold = bottom
		body.camera_left_threshhold = left
		body.camera_right_threshhold = right
		body.camera_top_threshhold = top
	pass # Replace with function body.
