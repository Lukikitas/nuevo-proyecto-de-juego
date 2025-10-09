extends Area2D

# --- EXPORT VARIABLES ---
@export var speed: float = 680.0
@export var damage: int = 10

# --- VARIABLES ---
var direction: Vector2 = Vector2.ZERO

# --- GODOT METHODS ---
func _ready() -> void:
	# Conectar la señal `body_entered` para detectar colisiones.
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Mover la bala en la dirección establecida.
	global_position += direction * speed * delta

# --- PUBLIC METHODS ---
func setup(start_position: Vector2, move_direction: Vector2) -> void:
	"""
	Inicializa la posición y dirección de la bala.
	Es llamado por el nodo que instancia la bala (ej. el Player).
	"""
	global_position = start_position
	direction = move_direction.normalized()

# --- SIGNAL HANDLERS ---
func _on_body_entered(body: Node) -> void:
	"""
	Se ejecuta cuando la bala colisiona con otro cuerpo físico.
	"""
	# Si el cuerpo tiene un método `take_damage`, le inflige daño.
	if body.has_method("take_damage"):
		body.take_damage(damage)

	# La bala se destruye al impactar.
	queue_free()
