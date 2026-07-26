extends CharacterBody2D



@export var health = 10
@export var drop: String
@export var player: CharacterBody2D
@export var movement_speed: float
@export var knockback_speed: float
@export var tilemap: TileMapLayer
@export var enemy_sprite: Node2D


@onready var eye: Node2D = $Eye
@onready var south_star_helper_points: Node2D
@onready var robot: Node2D

var start_spot: Vector2
var wander_spot: Vector2
var attacking: bool = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_spot = position

	south_star_helper_points = player.south_star_helper_points



	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_health()
	#move_enemy()
	destroy_tiles()
	move_eye()

	move_enemy(delta)

	pass



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

func move_enemy(delta: float):
	if player:
		if robot.is_laser_active == true:
			var direction: Vector2 = player.global_position.direction_to(global_position)
			
			velocity = direction * knockback_speed
		else:
			global_position = global_position.move_toward(player.global_position, movement_speed * delta)
	move_and_slide()




func _on_destruction_range_body_entered(body: Node2D) -> void:
	if body != player and body.name != "SouthStar" and !(body is TileMapLayer): body.queue_free()
	pass # Replace with function body.


func _on_attack_timer_timeout() -> void:
	#If the player is close enough, start attacking every 0.25 seconds
	if player:
		if player.position.distance_to(position) < 150:
			for area in $InteractionArea.get_overlapping_areas():
				if area.get_meta("type") == "attack":
					attacking = true
					for i in 10:
						if area:
							area.call("interaction")

					await get_tree().create_timer(0.5).timeout
					attacking = false
	pass # Replace with function body.
