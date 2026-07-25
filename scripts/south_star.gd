extends CharacterBody2D

const DISTANCE_TO_TARGET_TOLERANCE: = 50

const ATTACKS_BEFORE_CHASE = 3
const HEALTH_BEFORE_CHASE = 3

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
@onready var south_star_orbit_path_follow: PathFollow2D

var start_spot: Vector2
var wander_spot: Vector2
var attacking: bool = false

var target_pos: Vector2
var attack: int = 0

var state : = ""
var times_to_attack : = 0
var times_to_cycle : = 0
var selected_corner: Node2D
var times_attacked: = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_spot = position

	south_star_helper_points = player.south_star_helper_points
	south_star_orbit_path = south_star_helper_points.get_child(0)
	south_star_orbit_path_follow = south_star_orbit_path.get_child(0)



	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_health()
	#move_enemy()
	flip_sprite()
	destroy_tiles()
	move_eye()

	if player.health <= HEALTH_BEFORE_CHASE and times_attacked >= ATTACKS_BEFORE_CHASE:
		move_enemy()
	else:
		do_attack_moves(delta)

	pass

func do_attack_moves(delta: float):
	if attack == 0:
		const ATTACK_AMOUNT = 3
		attack = randi_range(1, ATTACK_AMOUNT)
		state = ""
		times_attacked += 1

		if attack == 1: # Dash
			const MIN_ATTACK_TIMES = 2
			const MAX_ATTACK_TIMES = 4

			times_to_attack = randi_range(MIN_ATTACK_TIMES, MAX_ATTACK_TIMES)

			target_pos = south_star_orbit_path.curve.get_closest_point(global_position) + south_star_orbit_path.global_position

		elif attack == 2: # spasm

			const MIN_ATTACK_TIMES = 4
			const MAX_ATTACK_TIMES = 9

			const MIN_CYCLE_TIMES = 2
			const MAX_CYCLE_TIMES = 5

			times_to_attack = randi_range(MIN_ATTACK_TIMES, MAX_ATTACK_TIMES)
			times_to_cycle = randi_range(MIN_CYCLE_TIMES, MAX_CYCLE_TIMES)



			var target_corner = randi_range(1, 4)
			
			selected_corner = south_star_helper_points.get_child(target_corner)
			target_pos = selected_corner.global_position

			$SpasmTimer.start()
		elif attack == 3: # circle
			state = "start_circle"
			south_star_orbit_path_follow.progress = 0
			times_to_attack = 1

			$CircleShootTimer.start()


	if attack == 1:
		dash(delta)
	elif attack == 2:
		spasm()
	elif  attack == 3:
		circle(delta)


	if times_to_attack <= 0:
		state = ""
		attack = 0

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
			times_to_attack -= 1
			print(times_to_attack)


	global_position = global_position.move_toward(target_pos, movement_speed * delta * dash_speed_multiplier)

func spasm():
	global_position = target_pos
	target_pos = selected_corner.global_position
	state = "spasm"

func circle(delta: float):
	south_star_orbit_path_follow.progress += movement_speed * delta
	global_position = south_star_orbit_path_follow.global_position
	
	const MAX_PATH_PROGRESS = 6300
	
	if south_star_orbit_path_follow.progress >= MAX_PATH_PROGRESS:
		attack == 0
		state = ""
		times_to_attack = 0


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


func _on_shoot_timer_timeout() -> void: # For Spasm
	const SOUTH_STAR_PROJECTILE = preload("res://scenes/prefabs/south_star_projectile.tscn")
	const ROTATION_OFFSET = 23

	var projectile = SOUTH_STAR_PROJECTILE.instantiate()
	add_child(projectile)
	projectile.global_position = global_position
	projectile.look_at(player.global_position)
	projectile.global_rotation_degrees += randi_range(-ROTATION_OFFSET, ROTATION_OFFSET)
	
	times_to_attack -= 1

	print(times_to_attack)

	if times_to_attack <= 0:
			const MIN_ATTACK_TIMES = 4
			const MAX_ATTACK_TIMES = 9

			times_to_attack = randi_range(MIN_ATTACK_TIMES, MAX_ATTACK_TIMES)

			times_to_cycle -= 1
			
			if times_to_cycle <= 0:
				attack = 0
				state = ""
			else:
				var target_corner = randi_range(1, 4)
				
				selected_corner = south_star_helper_points.get_child(target_corner)
				target_pos = selected_corner.global_position


	$SpasmTimer.start()


func _on_circle_shoot_timer_timeout() -> void: # For Circle
	const SOUTH_STAR_PROJECTILE = preload("res://scenes/prefabs/south_star_projectile.tscn")

	var projectile = SOUTH_STAR_PROJECTILE.instantiate()
	add_child(projectile)
	projectile.global_position = global_position
	projectile.look_at(player.global_position)

	$CircleShootTimer.start()
