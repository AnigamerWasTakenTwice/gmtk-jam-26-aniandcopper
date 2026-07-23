extends CharacterBody2D

@export var movement_speed: float
@export var movement_max_speed: float
@export var run_accel_multiplier: float
@export var run_max_speed_multiplier: float
var movement_direction: Vector2
@onready var interaction_area: Area2D = $InteractionArea
@export var health = 10

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
	# Movement Code
	movement_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Input.is_action_pressed("run"):
		velocity.x = clamp(velocity.x + movement_direction.normalized().x * movement_speed * 60 * delta * run_accel_multiplier, -movement_max_speed * run_max_speed_multiplier, movement_max_speed * run_max_speed_multiplier)
		velocity.y = clamp(velocity.y + movement_direction.normalized().y * movement_speed * 60 * delta * run_accel_multiplier, -movement_max_speed * run_max_speed_multiplier, movement_max_speed * run_max_speed_multiplier)
	else:
		velocity.x = clamp(velocity.x + movement_direction.normalized().x * movement_speed * 60 * delta, -movement_max_speed, movement_max_speed)
		velocity.y = clamp(velocity.y + movement_direction.normalized().y * movement_speed * 60 * delta, -movement_max_speed, movement_max_speed)
	velocity = lerp(velocity, Vector2.ZERO, 0.2)
	move_and_slide()
	
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
	
	#HP and Death
	if health <= 0:
		get_tree().change_scene_to_file("res://scenes/test.tscn")
	$UI/HealthBar.value = health
	pass

# For every area in the interaction area, if the type of interaction matches 
# what we're doing right now, run the interaction script on the area.
func interact(type: String):
	for area in interaction_area.get_overlapping_areas():
		if area.get_meta("type") == type and area != $Hitbox:
			if area.has_method("interaction"): area.call("interaction")
