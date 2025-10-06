extends CharacterBody2D

@export var speed: float = 300.0

func get_input() -> Vector2:
	var input_direction := Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_direction.y += 1
	if Input.is_action_pressed("ui_up"):
		input_direction.y -= 1
	return input_direction.normalized()

func _physics_process(delta: float) -> void:
	var direction := get_input()
	velocity = direction * speed
	move_and_slide()
