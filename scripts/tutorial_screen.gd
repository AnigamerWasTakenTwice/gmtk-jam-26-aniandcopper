extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_anything_pressed() and !$AnimationPlayer.is_playing():
		$AnimationPlayer.play("exit")
		await $AnimationPlayer.animation_finished
		get_tree().paused = false
		queue_free()
	pass
