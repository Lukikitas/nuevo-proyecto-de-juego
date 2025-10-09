extends Area2D

@export var experience_amount: int = 15
@export var drift_speed: float = 20.0

func _physics_process(delta: float) -> void:
	position.y += sin(Time.get_ticks_msec() / 300.0) * drift_speed * delta
