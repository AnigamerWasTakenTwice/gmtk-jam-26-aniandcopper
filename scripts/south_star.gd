extends CharacterBody2D

const DISTANCE_TO_TARGET_TOLERANCE: = 50


@export var health = 10
@export var drop: String
@export var player: CharacterBody2D
@export var movement_speed: float
@export var dash_speed_multiplier: float
@export var detection_range: float
@export var chase_range: float
@export var tilemap: TileMapLayer
@export var enemy_sprite: Node2D
@onready var eye: Node2D = $Eye

@onready var south_star_helper_points: Node2D

@onready var south_star_orbit_path: Path2D

var start_spot: Vector2
var wander_spot: Vector2
var attacking: bool = false

var target_pos: Vector2
var attack: int = 0

var state : = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_spot = position

	south_star_helper_points = player.south_star_helper_points
	south_star_orbit_path = south_star_helper_points.get_child(0)



	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_health()
	#move_enemy()
	flip_sprite()
	destroy_tiles()
	move_eye()

	if attack == 0:
		const ATTACK_AMOUNT = 1
		attack = randi_range(1, ATTACK_AMOUNT)
		state = ""
		
		
		if attack == 1: # Dash
			target_pos = south_star_orbit_path.curve.get_closest_point(global_position) + south_star_orbit_path.global_position

	if attack == 1:
		dash(delta)

	pass

func dash(delta: float):
	
	if state == "":

		if global_position.distance_to(target_pos) < DISTANCE_TO_TARGET_TOLERANCE:
			state = "dash"
			$DashDirection.look_at(player.global_position)
			target_pos = $DashDirection/Marker2D.global_position


	elif state == "dash":
		
		if global_position.distance_to(target_pos) < DISTANCE_TO_TARGET_TOLERANCE:
			state = ""
			target_pos = south_star_orbit_path.curve.get_closest_point(global_position) + south_star_orbit_path.global_position
		
	global_position = global_position.move_toward(target_pos, movement_speed * delta * dash_speed_multiplier)


func move_eye():
	if player:
		const EYE_OFFSET = -90
		eye.look_at(player.global_position)
		eye.global_rotation_degrees += EYE_OFFSET


func destroy_tiles():
	if tilemap:
		for x in range(-5, 5):
			for y in range(-5, 5):
				tilemap.set_cell(tilemap.local_to_map(position + Vector2(32 * x, 32 * y)))
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
			if !attacking: 
				velocity = position.direction_to(player.position) * movement_speed
				$InteractionArea.position = position.direction_to(player.position) * 128
			else: velocity = Vector2.ZERO
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
					attacking = true
					area.call("interaction")
					await get_tree().create_timer(0.5).timeout
					attacking = false
	pass # Replace with function body.


func _on_destruction_range_body_entered(body: Node2D) -> void:
	if body != player and body.name != "SouthStar" and !(body is TileMapLayer): body.queue_free()
	pass # Replace with function body.
