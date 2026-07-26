extends CharacterBody2D

const MOVEMENT_SPEED = 10000
const DISTANCE_TO_QUIT = 100

@export var player: CharacterBody2D

var death_triggered = false


@onready var eye: Node2D = $Eye

func _process(delta: float) -> void:
	global_position = global_position.move_toward(player.global_position, MOVEMENT_SPEED * delta)
	
	if global_position.distance_to(player.global_position) <= DISTANCE_TO_QUIT and !death_triggered:
		death_triggered = true
		player.get_node("SFX/static").volume_db = -10
		player.get_node("SFX/static").play()
		player.get_node("UI/Noise").modulate = Color.WHITE
		player.is_active = false
		$strike.play()
		await get_tree().create_timer(5).timeout
		get_tree().quit()
	
	move_eye()


func move_eye():
	if player:
		const EYE_OFFSET = -90
		eye.look_at(player.global_position)
		eye.global_rotation_degrees += EYE_OFFSET
