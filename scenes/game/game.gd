extends Node2D

const ASTEROIDS_BASE_COUNT: int = 10

const MAX_ASTEROID_SIZE = 2

const ASTEROIDS_SPAWN_DISTANCE_FROM_PLAYER_LOWER: int = 500
const ASTEROIDS_SPAWN_DISTANCE_FROM_PLAYER_UPPER: int = 750
const ASTEROIDS_MAX_DISTNACE_FROM_PLAYER = ASTEROIDS_SPAWN_DISTANCE_FROM_PLAYER_LOWER * 3

var asteroids_cap: int = ASTEROIDS_BASE_COUNT
var score: int = 0

@onready var player: RigidBody2D = %Player

var asteroid_scene := preload("res://scenes/entities/asteroid/asteroid.tscn")

func _on_increase_asteroids_cap_timer_timeout() -> void:
	asteroids_cap += floor(score / 10) + 1

func _on_spawn_asteroid_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("asteroids").size() < asteroids_cap:
		spawn_asteroid()

func spawn_asteroid() -> void:
	var asteroid: RigidBody2D = asteroid_scene.instantiate()
	asteroid.size = randi_range(1, MAX_ASTEROID_SIZE)
	
	# Distance away from player
	var spawn_distance = randf_range(ASTEROIDS_SPAWN_DISTANCE_FROM_PLAYER_LOWER, ASTEROIDS_SPAWN_DISTANCE_FROM_PLAYER_UPPER)
	# Angle away from right infront of the player
	var spawn_angle = randfn(player.rotation, PI / 3) # TODO: Look into spawning angle a bit more. At the time of writing, I am not sure if this is correct or not.
	
	# Initial force to spawn in with
	var spawn_force = randf_range(500, 4000)
	# A force to push slightly left and right
	var spawn_force_deviation = randf_range(-1500, 1500)
	
	asteroid.position = Vector2(0, -spawn_distance).rotated(spawn_angle) + player.position
	asteroid.linear_velocity = player.linear_velocity
	asteroid.apply_force(Vector2(spawn_force_deviation, spawn_force).rotated(spawn_angle))
	
	add_child(asteroid)
