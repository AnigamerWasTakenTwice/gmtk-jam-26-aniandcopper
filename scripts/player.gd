extends CharacterBody2D




@export var camera_bottom_threshhold: = 10000000
@export var camera_top_threshhold: = -10000000
@export var camera_left_threshhold: = -10000000
@export var camera_right_threshhold: = 10000000

@export var movement_speed: float
@export var movement_max_speed: float
@export var run_accel_multiplier: float
@export var run_max_speed_multiplier: float
@export var health = 10:
	set(new_hp):
		if health > new_hp: $SFX/damage.play()
		health = new_hp

@export var can_take_damage: bool = true


@onready var interaction_area: Area2D = $InteractionArea
@onready var player_sprite: AnimatedSprite2D = $Sprite2D
@onready var camera: Camera2D = %Camera2D
@onready var animation_player: AnimationPlayer = $UI/AnimationPlayer
@onready var damage_animation: AnimationPlayer = $DamageAnimation


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
	camera.limit_bottom = camera_bottom_threshhold
	camera.limit_left = camera_left_threshhold
	camera.limit_right = camera_right_threshhold
	camera.limit_top = camera_top_threshhold
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
	var aim_direction = position.direction_to(get_global_mouse_position())
	interaction_area.position = aim_direction * 128
	# All of the interaction buttons in the game.
	if Input.is_action_just_pressed("attack"): 
		$InteractionArea/ToolSprite.texture.region.position.x = 14
		if aim_direction.x > 0: $InteractionArea/SwingAnimation.play("swing_right")
		else: $InteractionArea/SwingAnimation.play("swing_left")
		interact("attack")
	if Input.is_action_just_pressed("interact"): interact("interact")
	if Input.is_action_just_pressed("tool"): 
		$InteractionArea/ToolSprite.texture.region.position.x = 7 * selected_tool
		interact(tools[selected_tool])
		if aim_direction.x > 0: $InteractionArea/SwingAnimation.play("swing_right")
		else: $InteractionArea/SwingAnimation.play("swing_left")
	
	# Cycles through tools to use for harvesting in the above line
	if Input.is_action_just_pressed("cycle"):
		if selected_tool < tools.size() - 1: selected_tool += 1
		else: selected_tool = 0

		const ICON_PIXEL_SIZE = 7

		if selected_tool == 0: $UI/ToolSelected.texture.region = Rect2(0, 0, ICON_PIXEL_SIZE, ICON_PIXEL_SIZE)
		elif selected_tool == 1: $UI/ToolSelected.texture.region = Rect2(ICON_PIXEL_SIZE, 0, ICON_PIXEL_SIZE, ICON_PIXEL_SIZE)
		
		
	if interaction_area.global_position.x > global_position.x:
		interaction_area.global_scale.x = 1
	else:
		interaction_area.global_scale.x = -1

func handle_health():
		#HP and Death
	if health <= 0:
		movement_max_speed = 0
		for item in Global.inventory.keys():
			Global.inventory[item] = Global.saved_inventory[item]
		Global.died_at = get_tree().current_scene.scene_file_path
		await get_tree().create_timer(1).timeout
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

func take_damage(damage: float):
	if can_take_damage:
		health -= damage
		damage_animation.play("take_damage")
		can_take_damage = false
	
