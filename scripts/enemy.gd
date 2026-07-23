extends CharacterBody2D

@export var health = 10
@export var drop: String
@export var player: CharacterBody2D
@export var movement_speed: float
@export var detection_range: float
@export var chase_range: float

@onready var enemy_sprite: AnimatedSprite2D = $Sprite2D

var start_spot: Vector2
var wander_spot: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_spot = position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_health()
	move_enemy()
	flip_sprite()

	pass

func handle_health():
	# If the enemy's health runs out, give the drop and delete the enemy.

	if health <= 0:
		Global.inventory[drop] += 1 
		queue_free()

func move_enemy():
	if player:
		# If the player is in range, chase after them.
		if player.position.distance_to(position) < detection_range and position.distance_to(start_spot) < chase_range:
			velocity = position.direction_to(player.position) * movement_speed
			$InteractionArea.position = position.direction_to(player.position) * 128
		else:
			# Else, go to a random wander spot and stop.
			if position.distance_to(wander_spot) > 3:
				velocity = position.direction_to(wander_spot) * movement_speed
			else: velocity = Vector2.ZERO
	move_and_slide()

func flip_sprite():
	var direction = velocity.normalized()
	
	if direction.x > 0:
		enemy_sprite.flip_h = false
	elif direction.x < 0:
		enemy_sprite.flip_h = true


func _on_wander_timer_timeout() -> void:
	# Every few seconds, generate a new spot to wander to around the starting spot.
	wander_spot = start_spot + Vector2(randf_range(-100, 100), randf_range(-100, 100))
	pass # Replace with function body.


func _on_attack_timer_timeout() -> void:
	#If the player is close enough, start attacking every 0.25 seconds
	if player:
		if player.position.distance_to(position) < 150:
			for area in $InteractionArea.get_overlapping_areas():
				if area.get_meta("type") == "attack":
					area.call("interaction")
	pass # Replace with function body.
