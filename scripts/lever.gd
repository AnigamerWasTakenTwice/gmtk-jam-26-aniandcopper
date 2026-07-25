extends CharacterBody2D

@export var doors: Array[Node2D]

func interaction():
	$Lever.flip_h = !$Lever.flip_h
	for door in doors:
		print("Old Value: " + str(door.is_active))
		door.is_active = !door.is_active
		print("New Value: " + str(door.is_active))
		
	pass
