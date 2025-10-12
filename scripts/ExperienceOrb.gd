extends Area2D

@export var experience_amount: int = 15
@export var drift_speed: float = 20.0

func _ready() -> void:
	add_to_group("xp_orb")

func _physics_process(delta: float) -> void:
	# Añade un sutil efecto de flotación vertical.
	position.y += sin(Time.get_ticks_msec() / 300.0) * drift_speed * delta
