extends StaticBody2D

@export var health = 10
@export var drop: String
@export var type: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Hitbox.set_meta("type", type)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health <= 0:
		Global.inventory[drop] += 1 
		queue_free()
	pass
