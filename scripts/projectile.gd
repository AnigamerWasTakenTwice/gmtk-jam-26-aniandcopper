extends Area2D


@export var speed = 250

const DECAY_TIME = 10

var from_south_star = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(DECAY_TIME).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += speed * delta * transform.x

func _on_area_2d_area_entered(area: Area2D) -> void:
	
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("interaction"):
		if from_south_star: body.interaction()
	if body.has_method("take_damage"):
		body.take_damage(1)


func _on_area_entered(area: Area2D) -> void:
	if area.get_meta("type") == "attack":
		if from_south_star: area.call("interaction")
