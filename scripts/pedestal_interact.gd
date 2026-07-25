extends Area2D

const PROGRESS_AMOUNT = 0.05

@onready var p_cannon: Sprite2D = $"../PCannon"
@onready var p_laser: Sprite2D = $"../PCannon/Laser"


func interaction():
	var p_cannon_progress = p_cannon.material.get("shader_parameter/progress")
	var p_laser_progress = p_laser.material.get("shader_parameter/progress")

	if p_cannon_progress <= 1:
		p_cannon.material.set("shader_parameter/progress", p_cannon_progress + PROGRESS_AMOUNT)
	else:
		p_laser.material.set("shader_parameter/progress", p_laser_progress - PROGRESS_AMOUNT)
