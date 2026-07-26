extends Node2D

const TENTACLE = preload("res://scenes/prefabs/tentacle.tscn")

const STATIC_AMOUNT = 0.25
const CAMERA_TRAUMA_AMOUNT = 0.5

const TENTACLE_MIN_AMOUNT = 3
const TENTACLE_MAX_AMOUNT = 9
const TENTACLE_RANGE = 1000
const MIN_TENTACLE_X_DISTANCE = 150

@onready var game_timer: Timer = $"../GameTimer"
@onready var roar_sfx: AudioStreamPlayer = $RoarSFX

@export var time_left_amounts: Array[int]

@export var level: = 1

var is_rumbling: = false

func _process(delta: float) -> void:
	
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
			
			
			if level >= 4:


				for j in randi_range(TENTACLE_MIN_AMOUNT, TENTACLE_MAX_AMOUNT):
					var tentacle = TENTACLE.instantiate()
					add_child(tentacle)
					
					var pos: Vector2 = $"../Player".global_position
					
					
					while abs(pos.x - $"../Player".global_position.x) <= MIN_TENTACLE_X_DISTANCE:
						var ran_x = $"../Player".global_position.x + randi_range(-TENTACLE_RANGE, TENTACLE_RANGE)
						var ran_y = $"../Player".global_position.y + randi_range(-TENTACLE_RANGE, TENTACLE_RANGE)
						
						pos = Vector2(ran_x, ran_y)
					
					tentacle.global_position = pos

func _on_roar_sfx_finished() -> void:
	if level >= 2:
		$"../Player"/UI/RedOverlay/Fade.play("fade_out")

	if level >= 3:
			if level >= 3: 
				$"../Player"/UI/Noise.modulate = Color(1, 1, 1, 0)
				is_rumbling = false
		
