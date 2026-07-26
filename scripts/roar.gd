extends Node2D


@onready var game_timer: Timer = $"../GameTimer"
@onready var roar_sfx: AudioStreamPlayer = $RoarSFX

@export var time_left_amounts: Array[int]

@export var level: = 1

func _process(delta: float) -> void:
	for i in time_left_amounts:
		if game_timer.time_left <= i:
			
			roar_sfx.play()
			time_left_amounts.erase(i)
