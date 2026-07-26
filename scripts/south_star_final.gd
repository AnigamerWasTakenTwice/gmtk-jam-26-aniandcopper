extends CharacterBody2D

const MOVEMENT_SPEED = 10000
const DISTANCE_TO_QUIT = 100

@export var player: CharacterBody2D


@onready var eye: Node2D = $Eye

func _process(delta: float) -> void:
	global_position = global_position.move_toward(player.global_position, MOVEMENT_SPEED * delta)
	
	if global_position.distance_to(player.global_position) <= DISTANCE_TO_QUIT:
		get_tree().quit()
	
	move_eye()


func move_eye():
	if player:
		const EYE_OFFSET = -90
		eye.look_at(player.global_position)
		eye.global_rotation_degrees += EYE_OFFSET
