extends Area2D

@export var speed: float = 800.0
@export var damage: int = 50

var direction := Vector2.RIGHT

func _ready() -> void:
	# Add the bullet to the "bullet" group
	add_to_group("bullet")
	# Connect the body_entered signal to handle collisions
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Move the bullet
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	# Check if the body is an enemy and has the take_damage method
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(damage)

	# Destroy the bullet on any collision with a physics body
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Destroy the bullet when it goes off-screen to save memory
	queue_free()
