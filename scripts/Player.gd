extends CharacterBody2D

# Señal emitida cuando la salud del jugador cambia.
signal health_changed(current_health, max_health)
# Señal emitida cuando la experiencia del jugador cambia.
signal experience_changed(current_experience, max_experience)

# --- EXPORT VARIABLES ---
@export var speed: float = 300.0
@export var bullet_scene: PackedScene
@export var max_health: int = 100
@export var shoot_interval: float = 0.45

# --- VARIABLES ---
var health: int
var experience: int = 0
var experience_to_next_level: int = 100

# --- NODES ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var shoot_timer: Timer = $ShootTimer

# --- GODOT METHODS ---
func _ready() -> void:
	add_to_group("player")
	health = max_health
	health_changed.emit(health, max_health)
	experience_changed.emit(experience, experience_to_next_level)
	_setup_shoot_timer()

func _physics_process(delta: float) -> void:
	velocity = _get_input_direction() * speed
	move_and_slide()

# --- PRIVATE METHODS ---
func _setup_shoot_timer() -> void:
	shoot_timer.wait_time = shoot_interval
	if not shoot_timer.timeout.is_connected(_on_shoot_timer_timeout):
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

func _get_input_direction() -> Vector2:
	var direction := Vector2.ZERO
	if Input.is_action_pressed("ui_right"): direction.x += 1
	if Input.is_action_pressed("ui_left"):  direction.x -= 1
	if Input.is_action_pressed("ui_down"):  direction.y += 1
	if Input.is_action_pressed("ui_up"):    direction.y -= 1
	return direction.normalized()

func _find_closest_enemy() -> Node2D:
	var enemies: Array[Node2D] = get_tree().get_nodes_in_group("enemy")
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

	var bullet := bullet_scene.instantiate() as Area2D
	get_tree().current_scene.add_child(bullet)
	await bullet.ready

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
