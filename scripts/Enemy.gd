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
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_bar_timer: Timer = %HealthBarTimer

# --- GODOT METHODS ---
func _ready() -> void:
	health = max_health
	player = get_tree().get_first_node_in_group("player")
	# Inicializar la barra de vida
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.visible = false

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	var direction := (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

# --- PRIVATE METHODS ---

func _drop_experience_orb() -> void:
	if not experience_orb_scene:
		push_warning("Asigna una escena de orbe de experiencia en el enemigo.")
		return

	# Obtener el contenedor de orbes de la escena principal
	var orb_container = get_tree().current_scene.get_node_or_null("OrbContainer")
	if not orb_container:
		push_error("La escena principal no tiene un nodo 'OrbContainer'")
		return

	var orb := experience_orb_scene.instantiate()
	orb_container.add_child(orb)
	orb.global_position = global_position

func _show_damage_effect() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(sprite, "modulate", Color(1, 0.2, 0.2, 1), 0.1)

# --- PUBLIC METHODS ---
func take_damage(amount: int) -> void:
	health -= amount
	_show_damage_effect()

	# Actualizar y mostrar la barra de vida
	health_bar.value = health
	health_bar.visible = true
	health_bar_timer.start()

	if health <= 0:
		_drop_experience_orb()
		queue_free()

# --- SIGNAL HANDLERS ---
func _on_damage_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(touch_damage)

func _on_health_bar_timer_timeout() -> void:
	health_bar.visible = false
