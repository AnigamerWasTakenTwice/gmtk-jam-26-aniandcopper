extends Area2D

@export var parent_has_take_damage_function: = false

func interaction():
	print("Ow")
	if parent_has_take_damage_function: get_parent().take_damage(1)
	else:  get_parent().health -= 1
