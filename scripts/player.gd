extends CharacterBody2D

@export var movement_speed: float
@export var movement_max_speed: float
@export var run_accel_multiplier: float
@export var run_max_speed_multiplier: float
@export var health = 10:
	set(new_hp):
		if health > new_hp: $SFX/damage.play()
		health = new_hp

@onready var interaction_area: Area2D = $InteractionArea
@onready var player_sprite: AnimatedSprite2D = $Sprite2D
@onready var camera: Camera2D = %Camera2D


var movement_direction: Vector2


var tools = [
	"axe",
	"pickaxe"
]

var selected_tool = 0
var checklist_visible = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	move_player(delta)
	handle_interaction_area()
	handle_health()
	handle_checklist()
	handle_static()


func move_player(delta: float):
	# Movement Code
	movement_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Input.is_action_pressed("run"):
		velocity.x = clamp(velocity.x + movement_direction.normalized().x * movement_speed * 60 * delta * run_accel_multiplier, -movement_max_speed * run_max_speed_multiplier, movement_max_speed * run_max_speed_multiplier)
		velocity.y = clamp(velocity.y + movement_direction.normalized().y * movement_speed * 60 * delta * run_accel_multiplier, -movement_max_speed * run_max_speed_multiplier, movement_max_speed * run_max_speed_multiplier)
	else:
		velocity.x = clamp(velocity.x + movement_direction.normalized().x * movement_speed * 60 * delta, -movement_max_speed, movement_max_speed)
		velocity.y = clamp(velocity.y + movement_direction.normalized().y * movement_speed * 60 * delta, -movement_max_speed, movement_max_speed)


	velocity = lerp(velocity, Vector2.ZERO, 0.2)

	# Animates the player sprite
	if movement_direction:
		player_sprite.play("run")
	else:
		player_sprite.play("idle")

	# Flips player to face direction they are running in
	if velocity.x > 0:
		player_sprite.flip_h = false
	elif velocity.x < 0:
		player_sprite.flip_h = true
	
	move_and_slide()

func handle_interaction_area():
	# Moves the interaction area to point to where the player is looking.
	interaction_area.position = position.direction_to(get_global_mouse_position()) * 128
	# All of the interaction buttons in the game.
	if Input.is_action_just_pressed("attack"): interact("attack")
	if Input.is_action_just_pressed("interact"): interact("interact")
	if Input.is_action_just_pressed("tool"): interact(tools[selected_tool])
	
	# Cycles through tools to use for harvesting in the above line
	if Input.is_action_just_pressed("cycle"):
		if selected_tool < tools.size() - 1: selected_tool += 1
		else: selected_tool = 0
		$UI/ToolSelected.text = tools[selected_tool]

func handle_health():
		#HP and Death
	if health <= 0:
		get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
	$UI/HealthBar.value = health
	
func handle_checklist():
	# Checklist
	if Input.is_action_just_pressed("checklist"): 
		if checklist_visible: $UI/AnimationPlayer.play("slide_checklist")
		else: $UI/AnimationPlayer.play_backwards("slide_checklist")
		checklist_visible = !checklist_visible
	if "quota" in get_parent():
		var i = 1
		for req in get_parent().quota.keys():
			if i > $UI/Checklist/VBoxContainer.get_child_count() - 1:
				var txt = Label.new()
				txt.label_settings = LabelSettings.new()
				txt.label_settings.font = load("res://assets/fonts/alagard.ttf")
				txt.text = req + ": " + var_to_str(Global.inventory[req]) + "/" + var_to_str(get_parent().quota[req])
				$UI/Checklist/VBoxContainer.add_child(txt)
				if Global.inventory[req] >= get_parent().quota[req]: 
					txt.modulate = Color.DARK_GREEN
				else:
					txt.modulate = Color.DARK_RED
			else:
				$UI/Checklist/VBoxContainer.get_child(i).text = req + ": " + var_to_str(Global.inventory[req]) + "/" + var_to_str(get_parent().quota[req])
				if Global.inventory[req] >= get_parent().quota[req]: 
					$UI/Checklist/VBoxContainer.get_child(i).modulate = Color.DARK_GREEN
				else:
					$UI/Checklist/VBoxContainer.get_child(i).modulate = Color.DARK_RED
			i += 1

func handle_static():
	if $UI/Noise.modulate.a > 0.2:
		$UI/Noise.texture.noise.seed += 1

# For every area in the interaction area, if the type of interaction matches 
# what we're doing right now, run the interaction script on the area.
func interact(type: String):
	for area in interaction_area.get_overlapping_areas():
		if area.get_meta("type") == type and area != $Hitbox:
			if area.has_method("interaction"): 
				area.call("interaction")
				if type == "attack": $SFX/attack.play()
				if type == "axe": $SFX/attack.play()
				if type == "pickaxe": $SFX/attack.play()
				if type == "interact": $SFX/pickup.play()


func _on_step_timer_timeout() -> void:
	if velocity.length() > 0.2 and !Input.is_action_pressed("run"):
		$SFX/step.pitch_scale = randf_range(0.8, 1.2)
		$SFX/step.play()
	pass # Replace with function body.


func _on_run_timer_timeout() -> void:
	if velocity.length() > 0.2 and Input.is_action_pressed("run"):
		$SFX/step.pitch_scale = randf_range(0.7, 1.3)
		$SFX/step.play()
	pass # Replace with function body.
