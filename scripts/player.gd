extends CharacterBody2D

@export var movement_speed: float
@export var movement_max_speed: float
var movement_direction: Vector2
@onready var interaction_area: Area2D = $InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	movement_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Input.is_action_pressed("run"):
		velocity.x = clamp(velocity.x + movement_direction.normalized().x * movement_speed * 60 * delta * 3, -movement_max_speed * 1.5, movement_max_speed * 1.5)
		velocity.y = clamp(velocity.y + movement_direction.normalized().y * movement_speed * 60 * delta * 3, -movement_max_speed * 1.5, movement_max_speed * 1.5)
	else:
		velocity.x = clamp(velocity.x + movement_direction.normalized().x * movement_speed * 60 * delta, -movement_max_speed, movement_max_speed)
		velocity.y = clamp(velocity.y + movement_direction.normalized().y * movement_speed * 60 * delta, -movement_max_speed, movement_max_speed)
	velocity = lerp(velocity, Vector2.ZERO, 0.2)
	move_and_slide()
	if movement_direction != Vector2.ZERO: 
		interaction_area.position = Vector2(0, -64) + (movement_direction * 96)
	if Input.is_action_just_pressed("attack"):
		interact("attack")
	if Input.is_action_just_pressed("interact"):
		interact("interact")
	pass

func interact(type: String):
	for area in interaction_area.get_overlapping_areas():
		if area.get_meta("type") == type:
			area.call("interaction")
