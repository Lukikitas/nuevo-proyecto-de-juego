extends CharacterBody2D

signal health_changed(current_health, max_health)
signal experience_changed(current_experience, max_experience)

@export var speed: float = 300.0
@export var bullet_scene: PackedScene
@export var max_health: int = 100
@export var shoot_interval: float = 0.45  # cadencia de disparo

var health: int
var experience: int = 0
var experience_to_next_level: int = 100

@onready var sprite: Sprite2D = $Sprite2D
@onready var shoot_timer: Timer = $ShootTimer

func _ready() -> void:
	add_to_group("player")
	health = max_health
	health_changed.emit(health, max_health)
	experience_changed.emit(experience, experience_to_next_level)

	# Timer de disparo
	shoot_timer.wait_time = shoot_interval
	if not shoot_timer.timeout.is_connected(_on_shoot_timer_timeout):
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

func get_input() -> Vector2:
	var d := Vector2.ZERO
	if Input.is_action_pressed("ui_right"): d.x += 1
	if Input.is_action_pressed("ui_left"):  d.x -= 1
	if Input.is_action_pressed("ui_down"):  d.y += 1
	if Input.is_action_pressed("ui_up"):    d.y -= 1
	return d.normalized()

func _physics_process(delta: float) -> void:
	velocity = get_input() * speed
	move_and_slide()

func find_closest_enemy() -> Node2D:
	var enemies: Array = get_tree().get_nodes_in_group("enemy")
	var closest: Node2D = null
	var min_d2 := INF
	for e in enemies:
		if not is_instance_valid(e): continue
		var d2 := global_position.distance_squared_to(e.global_position)
		if d2 < min_d2:
			min_d2 = d2
			closest = e
	return closest

func _on_shoot_timer_timeout() -> void:
	if not bullet_scene: 
		push_warning("Asigna Bullet.tscn en 'bullet_scene' del Player")
		return
	var target := find_closest_enemy()
	if not target: 
		return

	var b := bullet_scene.instantiate()
	get_tree().current_scene.add_child(b)
	await b.ready

	var dir := (target.global_position - global_position).normalized()
	b.setup(global_position, dir)  # sale desde el jugador y apunta al más cercano

func take_damage(amount: int) -> void:
	health -= amount
	health_changed.emit(health, max_health)

	var t = create_tween()
	t.tween_property(sprite, "modulate", Color.RED, 0.1)
	t.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	if health <= 0:
		get_tree().reload_current_scene()

func _on_orb_collector_area_entered(area: Area2D) -> void:
	if "experience_amount" in area:
		experience += area.experience_amount
		while experience >= experience_to_next_level:
			experience -= experience_to_next_level
			experience_to_next_level = int(experience_to_next_level * 1.5)
		experience_changed.emit(experience, experience_to_next_level)
		area.queue_free()
