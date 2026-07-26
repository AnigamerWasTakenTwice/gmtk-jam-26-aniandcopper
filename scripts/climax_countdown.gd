extends Node2D

const ADDITIONAl_TIME = 13

@export var timer: Timer
@export var timer_label: Label
@export_file("*.tscn") var monster: String
@export var monster_spawn_pos: Vector2
@export var tilemap: TileMapLayer

@export var max_static: = 0.25

@export var music: AudioStreamPlayer
@export var music_panic: AudioStreamPlayer

@onready var player: CharacterBody2D = $Player
@onready var robot: Area2D = $Pedestal/Interact

var monster_inst: CharacterBody2D

var is_monster_present: bool = false
var has_monster_died: bool = false

var died_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	timer_label = $Player/UI/Countdown

	# Spawns the monster when the timer runs out.
	timer.connect("timeout", func():
		music.stop()
		await get_tree().create_timer(0.5).timeout
		music_panic.play()
		timer_label.text = "KILLITKILLITKILLITKILLITKILLITKILLITKILLITKILLITKILLITKILLITKILLITKILLIT"
		is_monster_present = true
		monster_inst = load(monster).instantiate()
		monster_inst.position = get_monster_position()
		monster_inst.player = $Player
		monster_inst.robot = robot
		if tilemap: monster_inst.tilemap = tilemap
		add_child(monster_inst)
		player.get_node("SFX/static").play()
		)
	pass # Replace with function body.

func get_monster_position():
	var pos: Vector2
	var south_star_points: Node2D = $Player/Camera2D/SouthStarHelperPoints
	var current_farthest_point: Node2D

	for child in south_star_points.get_children():
		if child.name != "Path":
			if current_farthest_point == null: current_farthest_point = child
			elif robot.global_position.distance_to(child.global_position) > robot.global_position.distance_to(current_farthest_point.global_position):
				current_farthest_point = child
	
	return current_farthest_point.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# If the timer hasn't ran out, the timer label shows how much time is left.
	if robot.is_robot_active:
		timer.paused = true
		
		if has_monster_died: timer_label.text = "    Thank you for playing!\n    Exit from the door on the top \n   to return to the title screen!"
		elif not robot.is_laser_active or not is_monster_present: timer_label.text = "CAN'T HIDE FOR LONG"

	else:
		if timer.time_left > 0: timer_label.text = var_to_str(int(timer.time_left - ADDITIONAl_TIME))
		if timer.paused: timer.paused = false

	
	if timer.time_left < ADDITIONAl_TIME: music.stop()
	
	if is_instance_valid(monster_inst):
		if "death_triggered" in monster_inst:
			if monster_inst.death_triggered == true: $music_fakeout.stop()
	
	if is_monster_present:
		const TRAUMA_AMOUNT = 0.5
		
		player.camera.set_trauma(TRAUMA_AMOUNT)
		player.get_node("Hitbox").parent_has_take_damage_function = false
		player.get_node("UI/Noise").modulate = Color(1, 1, 1, remap(player.position.distance_to(monster_inst.position), 0, 1000, max_static, 0))
		player.get_node("UI/RedOverlay").visible = true
		if player.health == 0: max_static = lerp(max_static, 1.0, 0.2)
		player.get_node("SFX/static").volume_db = remap(player.position.distance_to(monster_inst.position), 0, 1000, -10, -80)
	pass


func kill_monster():
	is_monster_present = false
	has_monster_died = true
	died_position = monster_inst.global_position
	monster_inst.queue_free()
	music_panic.stop()
	player.get_node("UI/RedOverlay").visible = false
	timer_label.text = "Escape"
	player.get_node("SFX/static").stop()
	$music_fakeout.play()
	$Door.is_active = false


func _on_respawn_area_body_entered(body: Node2D) -> void:
	if has_monster_died:
		monster_inst = preload("res://scenes/prefabs/south_star_final.tscn").instantiate()
		monster_inst.position = died_position
		monster_inst.player = $Player
		add_child(monster_inst)
