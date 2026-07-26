extends Area2D

const TENTACLE_SPRITE_1 = preload("res://assets/sprites/south_star/tentacle.png")
const TENTACLE_SPRITE_2 = preload("res://assets/sprites/south_star/tentacle2.png")


func _ready() -> void:
	$AnimationPlayer.play("grow")
	var ran = randi_range(0, 1)
	
	if ran == 0:
		$Tentacle.texture = TENTACLE_SPRITE_1
	else:
		$Tentacle.texture = TENTACLE_SPRITE_2
