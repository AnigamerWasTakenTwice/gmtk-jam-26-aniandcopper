extends Node2D


@export var timer: Timer
@export var timer_label: Label
@export var quota: Dictionary
@export var exit_area: Area2D
@export_file("*.tscn") var monster: String
@export var monster_spawn_pos: Vector2
@export_file("*.tscn") var exit_to: String
@export var tilemap: TileMapLayer

@export var max_static: = 0.25

@onready var player: CharacterBody2D = $Player

var monster_inst: CharacterBody2D

var is_monster_present: bool = false

@export var music: AudioStreamPlayer
@export var music_panic: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Loops through each requirement in the quota to see if the player can leave.
	#If they can, move them to the next area.
	exit_area.connect("body_entered", func(body):
		if body.name == "Player":
			var requirements_met = true
			for req in quota.keys():
				if Global.inventory[req] < quota[req]:
					requirements_met = false
			if requirements_met:
				for item in Global.inventory.keys():
					Global.inventory[item] = 0
				music.stop()
				music_panic.stop()
				player.get_node("UI/AnimationPlayer").play("exit")
				await get_tree().create_timer(4).timeout
				get_tree().change_scene_to_file(exit_to)
			else: 
				print("OUTTA HERE")
				player.animation_player.play("jiggle_checklist")
				player.checklist_visible = true
		)
	
	# Spawns the monster when the timer runs out.
	timer.connect("timeout", func():
		music.stop()
		await get_tree().create_timer(0.5).timeout
		music_panic.play()
		timer_label.text = "RUNRUNRUNRUNRUNRUNRUNRUNRUNRURNRUNRUNRUNRUNRUNRUN"
		is_monster_present = true
		monster_inst = load(monster).instantiate()
		monster_inst.position = monster_spawn_pos
		monster_inst.player = $Player
		if tilemap: monster_inst.tilemap = tilemap
		add_child(monster_inst)
		player.get_node("SFX/static").play()
		)
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# If the timer hasn't ran out, the timer label shows how much time is left.
	if timer.time_left > 0: timer_label.text = var_to_str(int(timer.time_left))
	
	if is_monster_present:
		const TRAUMA_AMOUNT = 0.5
		
		player.camera.set_trauma(TRAUMA_AMOUNT)
		player.get_node("Hitbox").parent_has_take_damage_function = false
		player.get_node("UI/Noise").modulate = Color(1, 1, 1, remap(player.position.distance_to(monster_inst.position), 0, 1000, max_static, 0))
		if player.health == 0: max_static = lerp(max_static, 1.0, 0.2)
		player.get_node("SFX/static").volume_db = remap(player.position.distance_to(monster_inst.position), 0, 1000, -10, -80)
	pass
