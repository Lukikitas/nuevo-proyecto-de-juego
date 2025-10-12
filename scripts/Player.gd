extends CharacterBody2D

# Señal emitida cuando la salud del jugador cambia.
signal health_changed(current_health, max_health)
# Señal emitida cuando la experiencia del jugador cambia.
signal experience_changed(current_experience, max_experience)

# --- EXPORT VARIABLES ---
@export var speed: float = 300.0
@export var bullet_scene: PackedScene
@export var max_health: int = 100
@export var shoot_interval: float = 0.5

# --- VARIABLES ---
var health: int
var experience: int = 0
var experience_to_next_level: int = 100

# --- NODES ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var shoot_timer: Timer = $ShootTimer

# --- GODOT METHODS ---
func _ready() -> void:
	health = max_health
	health_changed.emit(health, max_health)
	experience_changed.emit(experience, experience_to_next_level)
	shoot_timer.wait_time = shoot_interval

func _physics_process(delta: float) -> void:
	velocity = _get_input_direction() * speed
	move_and_slide()

# --- PRIVATE METHODS ---
func _get_input_direction() -> Vector2:
	var direction := Vector2.ZERO
	if Input.is_action_pressed("move_right"): direction.x += 1
	if Input.is_action_pressed("move_left"):  direction.x -= 1
	if Input.is_action_pressed("move_down"):  direction.y += 1
	if Input.is_action_pressed("move_up"):    direction.y -= 1
	return direction.normalized()

func _find_closest_enemy() -> Node2D:
	var enemies: Array = get_tree().get_nodes_in_group("enemy")
	var closest_enemy: Node2D = null
	var min_distance_sq: float = INF

	for enemy in enemies:
		if not is_instance_valid(enemy): continue
		var distance_sq := global_position.distance_squared_to(enemy.global_position)
		if distance_sq < min_distance_sq:
			min_distance_sq = distance_sq
			closest_enemy = enemy
	return closest_enemy

func _shoot_at(target: Node2D) -> void:
	if not bullet_scene:
		push_warning("Asigna Bullet.tscn en 'bullet_scene' del Player")
		return

	# Obtener el contenedor de balas de la escena principal
	var bullet_container = get_tree().current_scene.get_node_or_null("BulletContainer")
	if not bullet_container:
		push_error("La escena principal no tiene un nodo 'BulletContainer'")
		return

	var bullet := bullet_scene.instantiate() as Area2D
	bullet_container.add_child(bullet)

	var direction := (target.global_position - global_position).normalized()
	if bullet.has_method("setup"):
		bullet.setup(global_position, direction)

func _show_damage_effect() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

# --- PUBLIC METHODS ---
func take_damage(amount: int) -> void:
	health -= amount
	health_changed.emit(health, max_health)
	_show_damage_effect()

	if health <= 0:
		get_tree().reload_current_scene()

func collect_experience(amount: int) -> void:
	experience += amount
	while experience >= experience_to_next_level:
		experience -= experience_to_next_level
		experience_to_next_level = int(experience_to_next_level * 1.5)
	experience_changed.emit(experience, experience_to_next_level)

# --- SIGNAL HANDLERS ---
func _on_shoot_timer_timeout() -> void:
	var target := _find_closest_enemy()
	if target:
		_shoot_at(target)

func _on_orb_collector_area_entered(area: Area2D) -> void:
	if "experience_amount" in area:
		collect_experience(area.experience_amount)
		area.queue_free()
