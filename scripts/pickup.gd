extends Area2D

@export var item: String

func interaction():
	Global.inventory[item] += 1
	print(Global.inventory)
	queue_free()
