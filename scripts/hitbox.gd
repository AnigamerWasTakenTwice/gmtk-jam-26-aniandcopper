extends Area2D


func interaction():
	print("Ow")
	get_parent().health -= 1
