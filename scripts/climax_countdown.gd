extends Node2D

const ADDITIONAl_TIME = 10

@export var timer: Timer
@export var timer_label: Label
@export_file("*.tscn") var monster: String
@export var monster_spawn_pos: Vector2
@export var tilemap: TileMapLayer

@export var max_static: = 0.25

@onready var player: CharacterBody2D = $Player
@onready var robot: Area2D = $Pedestal/Interact

var monster_inst: CharacterBody2D

var is_monster_present: bool = false

@export var music: AudioStreamPlayer
@export var music_panic: AudioStreamPlayer

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
		monster_inst.position = monster_spawn_pos
		monster_inst.player = $Player
		monster_inst.robot = robot
		if tilemap: monster_inst.tilemap = tilemap
		add_child(monster_inst)
		player.get_node("SFX/static").play()
		)
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# If the timer hasn't ran out, the timer label shows how much time is left.
	print(timer)
	print(timer_label)
	if timer.time_left > 0: timer_label.text = var_to_str(int(timer.time_left - ADDITIONAl_TIME))
	
	if timer.time_left < ADDITIONAl_TIME: music.stop()
	
	
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
	monster_inst.queue_free()
	music_panic.stop()
	player.get_node("UI/RedOverlay").visible = false
	timer_label.text = "Escape"
	player.get_node("SFX/static").stop()
