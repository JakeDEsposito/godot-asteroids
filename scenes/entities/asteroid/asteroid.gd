extends RigidBody2D

const RESOLUTION: int = 12
const ANGLE_STEP: float = PI * 2 / RESOLUTION

const MAX_ASTEROID_SIZE: int = 2

@export_range(0, MAX_ASTEROID_SIZE) var size: int = randi_range(1, MAX_ASTEROID_SIZE)

func _ready() -> void:
	var asteroid = Line2D.new()
	asteroid.closed = true
	asteroid.width = 1
	asteroid.default_color = Color(0, 255, 0)
	asteroid.joint_mode = Line2D.LINE_JOINT_ROUND
	
	for i in RESOLUTION:
		var theta = i * ANGLE_STEP
		var point = Vector2(cos(theta), sin(theta))
		
		if i % 3 == 0:
			# x controls depth of crater.
			# y controls shift of crater.
			var crater = Vector2(randf_range(0.2, 0.5), randf_range(-0.4, 0.4))
			
			point -= crater.rotated(theta)
		
		asteroid.add_point(point * 10)
	
	add_child(asteroid)
	
	scale *= size

func takeHit() -> void:
	size -= 1
	
	if size > 0:
		var asteroid_scene: PackedScene = load(scene_file_path)
		
		var meteoroids: Array[PackedScene] = Array()
		
		var meteoroids_count := randi_range(1, 3)
		var angle_step := PI * 2 / meteoroids_count
		
		for i in meteoroids_count:
			var theta := i * angle_step
			
			var asteroid: RigidBody2D = asteroid_scene.instantiate()
			asteroid.position = Vector2(cos(theta), sin(theta)) * size * 10 + position
			asteroid.linear_velocity = linear_velocity
			asteroid.apply_force(Vector2.UP.rotated(theta) * randf_range(1, 10))
			
			# TODO: Add to scene
	
	queue_free()

func _on_body_entered(body: Node) -> void:
	takeHit()
