extends Area2D

@export var speed: float = 680.0
@export var damage: int = 10
@export var lifetime: float = 3.0 # Tiempo de vida para autodestrucción

# --- VARIABLES ---
var direction: Vector2 = Vector2.ZERO
var _time_elapsed: float = 0.0

# --- GODOT METHODS ---
func _ready() -> void:
	pass # Las conexiones de señales se manejan en el editor.

func _physics_process(delta: float) -> void:
	# Mover la bala en la dirección establecida.
	global_position += direction * speed * delta

	# Comprobar el tiempo de vida
	_time_elapsed += delta
	if _time_elapsed >= lifetime:
		queue_free()

# --- PUBLIC METHODS ---
func setup(start_position: Vector2, move_direction: Vector2) -> void:
	"""
	Inicializa la posición y dirección de la bala.
	Es llamado por el nodo que instancia la bala (ej. el Player).
	"""
	global_position = start_position
	direction = move_direction.normalized()
	rotation = direction.angle()

# --- SIGNAL HANDLERS ---
func _on_body_entered(body: Node) -> void:
	"""
	Se ejecuta cuando la bala colisiona con otro cuerpo físico.
	"""
	# Si el cuerpo es un enemigo, le inflige daño.
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		# La bala se destruye solo si impacta con un enemigo.
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	"""
	Se ejecuta cuando la bala sale de la pantalla para destruirla y liberar memoria.
	"""
	queue_free()
