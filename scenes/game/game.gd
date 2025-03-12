extends Node2D

const ASTEROIDS_BASE_COUNT: int = 10

const MAX_ASTEROID_SIZE: int = 2

const ASTEROIDS_SPAWN_DISTANCE_FROM_PLAYER_LOWER: int = 500
const ASTEROIDS_SPAWN_DISTANCE_FROM_PLAYER_UPPER: int = 750
const ASTEROIDS_MAX_DISTANCE_FROM_PLAYER: int = 1500

var asteroids_cap: int = ASTEROIDS_BASE_COUNT
var score: int = 0

@onready var player: RigidBody2D = %Player
@onready var game_ui: Control = %GameUI

const asteroid_scene: PackedScene = preload("res://scenes/entities/asteroid/asteroid.tscn")
const gameover_ui: PackedScene = preload("res://scenes/ui/gameover.tscn")

func _on_increase_asteroids_cap_timer_timeout() -> void:
	asteroids_cap += floori(score / 10.0) + 1

func _on_spawn_asteroid_timer_timeout() -> void:
	var asteroids: Array[Node] = get_tree().get_nodes_in_group("asteroids")
	
	for asteroid: Node in asteroids:
		if player.global_position.distance_squared_to(asteroid.global_position) > ASTEROIDS_MAX_DISTANCE_FROM_PLAYER * ASTEROIDS_MAX_DISTANCE_FROM_PLAYER:
			asteroid.queue_free()
	
	if asteroids.size() < asteroids_cap:
		spawn_asteroid()

func spawn_asteroid() -> void:
	var asteroid: RigidBody2D = asteroid_scene.instantiate()
	
	# Distance away from player
	var spawn_distance: float = randf_range(ASTEROIDS_SPAWN_DISTANCE_FROM_PLAYER_LOWER, ASTEROIDS_SPAWN_DISTANCE_FROM_PLAYER_UPPER)
	# Angle away from right infront of the player
	var spawn_angle: float = randfn(player.rotation, PI / 3) # TODO: Look into spawning angle a bit more. At the time of writing, I am not sure if this is correct or not.
	
	# Initial force to spawn in with
	var spawn_force: float = randf_range(500, 4000)
	# A force to push slightly left and right
	var spawn_force_deviation: float = randf_range(-1500, 1500)
	
	asteroid.position = Vector2(0, -spawn_distance).rotated(spawn_angle) + player.position
	asteroid.linear_velocity = player.linear_velocity
	asteroid.apply_force(Vector2(spawn_force_deviation, spawn_force).rotated(spawn_angle))
	
	add_child(asteroid)

func _on_player_health_updated(new_health: int) -> void:
	game_ui.set_lives(new_health)

func _on_player_score_updated(new_score: int) -> void:
	game_ui.set_score(new_score)
	score = new_score
