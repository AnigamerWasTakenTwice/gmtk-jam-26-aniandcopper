extends Node2D

const STATIC_AMOUNT = 0.25
const CAMERA_TRAUMA_AMOUNT = 0.5

@onready var game_timer: Timer = $"../GameTimer"
@onready var roar_sfx: AudioStreamPlayer = $RoarSFX

@export var time_left_amounts: Array[int]

@export var level: = 1

var is_rumbling: = false

func _process(delta: float) -> void:
	print()
	
	if is_rumbling:
		$"../Player"/Camera2D.set_trauma(CAMERA_TRAUMA_AMOUNT)

	
	for i in time_left_amounts:
		if game_timer.time_left <= i:
			
			roar_sfx.play()
			time_left_amounts.erase(i)



			if level >= 2: $"../Player"/UI/RedOverlay/Fade.play("fade_in")
			
			if level >= 3: 
				$"../Player"/UI/Noise.modulate = Color(1, 1, 1, STATIC_AMOUNT)
				is_rumbling = true


func _on_roar_sfx_finished() -> void:
	if level >= 2:
		$"../Player"/UI/RedOverlay/Fade.play("fade_out")

	if level >= 3:
			if level >= 3: 
				$"../Player"/UI/Noise.modulate = Color(1, 1, 1, 0)
				is_rumbling = false
		
