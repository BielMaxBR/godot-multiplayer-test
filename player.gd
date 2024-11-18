extends CharacterBody2D
class_name Player

var is_local: bool
var id: int
@export var speed = 400


	
func _physics_process(delta: float) -> void:
	if is_local:
		var direction = Input.get_vector("left","right","up","down")
		velocity = direction * speed
		move_and_slide()
