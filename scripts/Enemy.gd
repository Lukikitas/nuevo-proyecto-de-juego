extends CharacterBody2D

# --- EXPORT VARIABLES ---
@export var speed: float = 90.0
@export var touch_damage: int = 10
@export var max_health: int = 20
@export var experience_orb_scene: PackedScene

# --- VARIABLES ---
var health: int
var player: Node2D

# --- NODES ---
@onready var sprite: Sprite2D = $Sprite2D

# --- GODOT METHODS ---
func _ready() -> void:
	add_to_group("enemy")
	health = max_health
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	var direction := (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	_handle_contact_damage()

# --- PRIVATE METHODS ---
func _handle_contact_damage() -> void:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider and collider.is_in_group("player"):
			if collider.has_method("take_damage"):
				collider.take_damage(touch_damage)

func _drop_experience_orb() -> void:
	if not experience_orb_scene:
		push_warning("Asigna una escena de orbe de experiencia en el enemigo.")
		return

	var orb := experience_orb_scene.instantiate()
	get_tree().current_scene.add_child(orb)
	orb.global_position = global_position

func _show_damage_effect() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(sprite, "modulate", Color(1, 0.2, 0.2, 1), 0.1)

# --- PUBLIC METHODS ---
func take_damage(amount: int) -> void:
	health -= amount
	_show_damage_effect()

	if health <= 0:
		_drop_experience_orb()
		queue_free()
