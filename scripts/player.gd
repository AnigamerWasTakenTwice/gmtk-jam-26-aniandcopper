extends CharacterBody2D

@export var movement_speed: float
@export var movement_max_speed: float
@export var run_accel_multiplier: float
@export var run_max_speed_multiplier: float
@export var health = 10

@onready var interaction_area: Area2D = $InteractionArea
@onready var player_sprite: AnimatedSprite2D = $Sprite2D


var movement_direction: Vector2


var tools = [
	"axe",
	"pickaxe"
]

var selected_tool = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	move_player(delta)
	handle_interaction_area()
	handle_health()
	handle_checklist()


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
	if movement_direction != Vector2.ZERO: 
		interaction_area.position = movement_direction * 96
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
		get_tree().change_scene_to_file("res://scenes/test.tscn")
	$UI/HealthBar.value = health
	
func handle_checklist():
	# Checklist
	if Input.is_action_just_pressed("checklist"): 
		$UI/Checklist.visible = !$UI/Checklist.visible
	if "quota" in get_parent():
		var i = 1
		for req in get_parent().quota.keys():
			if i > $UI/Checklist/VBoxContainer.get_child_count() - 1:
				var txt = Label.new()
				txt.text = req + ": " + var_to_str(Global.inventory[req]) + "/" + var_to_str(get_parent().quota[req])
				$UI/Checklist/VBoxContainer.add_child(txt)
				if Global.inventory[req] >= get_parent().quota[req]: 
					txt.modulate = Color.GREEN
				else:
					txt.modulate = Color.RED
			else:
				$UI/Checklist/VBoxContainer.get_child(i).text = req + ": " + var_to_str(Global.inventory[req]) + "/" + var_to_str(get_parent().quota[req])
				if Global.inventory[req] >= get_parent().quota[req]: 
					$UI/Checklist/VBoxContainer.get_child(i).modulate = Color.GREEN
				else:
					$UI/Checklist/VBoxContainer.get_child(i).modulate = Color.RED
			i += 1

# For every area in the interaction area, if the type of interaction matches 
# what we're doing right now, run the interaction script on the area.
func interact(type: String):
	for area in interaction_area.get_overlapping_areas():
		if area.get_meta("type") == type and area != $Hitbox:
			if area.has_method("interaction"): area.call("interaction")
