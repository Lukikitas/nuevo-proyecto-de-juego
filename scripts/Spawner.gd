extends Node

@export var enemy_scene: PackedScene
@export var experience_orb_scene: PackedScene

# --- EXPORT VARIABLES PARA LA PROGRESIÓN ---
@export var initial_spawn_rate: float = 1.0  # Enemigos por segundo al inicio
@export var final_spawn_rate: float = 5.0    # Enemigos por segundo al final
@export var acceleration_time: float = 60.0  # Segundos para alcanzar la tasa final

# --- NODES ---
@onready var spawn_location: PathFollow2D = %SpawnLocation
@onready var spawn_timer: Timer = $Timer

# --- VARIABLES ---
var elapsed_time: float = 0.0

# --- GODOT METHODS ---
func _process(delta: float) -> void:
	# Incrementar el tiempo transcurrido
	elapsed_time += delta

	# Calcular la progresión actual (de 0.0 a 1.0)
	var progress = min(elapsed_time / acceleration_time, 1.0)

	# Interpolar la tasa de aparición actual
	var current_spawn_rate = lerp(initial_spawn_rate, final_spawn_rate, progress)

	# Actualizar el temporizador. wait_time es el inverso de la tasa (si la tasa es 2 E/s, el tiempo es 0.5s)
	spawn_timer.wait_time = 1.0 / current_spawn_rate

func _on_timer_timeout() -> void:
	# Obtener una ubicación aleatoria en la ruta
	spawn_location.progress_ratio = randf()

	# Instanciar la escena del enemigo
	var enemy = enemy_scene.instantiate()

	# Asignar la escena del orbe de experiencia a la instancia del enemigo
	enemy.experience_orb_scene = experience_orb_scene

	# Establecer la posición global del enemigo
	enemy.global_position = spawn_location.global_position

	# Añadir el enemigo al árbol de escenas, como hijo de la escena principal (Main)
	owner.add_child(enemy)
