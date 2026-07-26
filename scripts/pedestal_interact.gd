extends Area2D

const PROGRESS_AMOUNT = 0.05
const P_LASER_DISTANCE = 48
const P_LASER_ROTATION_OFFSET_IDLE = 90
const P_LASER_ROTATION_OFFSET_ATTACKING = -90

const TIME_UNTIL_MONSTER_DEATH = 2.5
const TIME_UNTIL_LASER_DEACTIVATES = 5

@onready var p_cannon: Sprite2D = $"../PCannon"
@onready var p_laser: Sprite2D = $"../PCannon/Laser"
@onready var player: CharacterBody2D = $"../../Player"

var has_finished_yet: bool = false
var is_robot_active: bool = false
var is_laser_active: bool = false



var previous_player_pos: Vector2

func _ready() -> void:
	p_cannon.material.set("shader_parameter/progress", 1)#0.25)
	p_laser.material.set("shader_parameter/progress", 0)#1)

func _process(delta: float) -> void:
	move_robot()

func interaction():
	var p_cannon_progress = p_cannon.material.get("shader_parameter/progress")
	var p_laser_progress = p_laser.material.get("shader_parameter/progress")

	if p_cannon_progress <= 1:
		p_cannon.material.set("shader_parameter/progress", p_cannon_progress + PROGRESS_AMOUNT)
	elif p_laser_progress >= 0:
		p_laser.material.set("shader_parameter/progress", p_laser_progress - PROGRESS_AMOUNT)
	elif !has_finished_yet:
		$"../Animation".play("finish_building")
		has_finished_yet = true
	else:
		enter_robot()

func enter_robot():
	player.is_active = false
	player.camera.enabled = false

	previous_player_pos = player.global_position
	player.global_position = global_position

	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	is_robot_active = true
	$"../CannonCamera".enabled = true

func exit_robot():
	player.is_active = true
	player.camera.enabled = true
	player.global_position = previous_player_pos
	is_robot_active = false
	$"../CannonCamera".enabled = false

func move_robot():
	if !is_robot_active or is_laser_active: return
	
	if Input.is_action_just_pressed("interact") and not is_laser_active: exit_robot()



	if $"../..".is_monster_present:
		var aim_direction = position.direction_to($"../..".monster_inst.position)

		p_laser.position = aim_direction * P_LASER_DISTANCE
		
		p_laser.look_at($"../..".monster_inst.position)
		p_laser.global_rotation_degrees += P_LASER_ROTATION_OFFSET_ATTACKING
		
		

	else:
		var aim_direction = position.direction_to(get_global_mouse_position())

		p_laser.position = aim_direction * P_LASER_DISTANCE

		p_laser.look_at(p_cannon.global_position)
		p_laser.global_rotation_degrees += P_LASER_ROTATION_OFFSET_IDLE


	if Input.is_action_just_pressed("attack") and $"../..".is_monster_present and not is_laser_active:
		$"../Animation".play("fire")
		is_laser_active = true

		await get_tree().create_timer(TIME_UNTIL_MONSTER_DEATH).timeout
		$"../..".kill_monster()

		await get_tree().create_timer(TIME_UNTIL_LASER_DEACTIVATES).timeout
		$"../PCannon/Laser/SuperLaserPiss".visible = false
		is_laser_active = false
		$"../Animation".stop()
		
