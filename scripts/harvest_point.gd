extends StaticBody2D

@export var health = 10
@export var item: PackedScene
@export var type: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Hitbox.set_meta("type", type)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health <= 0:
		if item:
			var drop = item.instantiate()
			get_parent().add_child(drop)
			drop.global_position = $Hitbox.global_position

		queue_free()
	pass

func take_damage(damage: float):
	health -= damage
	$AnimationPlayer.play("shake")
