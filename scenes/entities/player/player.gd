extends RigidBody2D

const ROTATE_SPEED: float = 4.5
const MOVE_SCALER: float = 0.6

func _ready() -> void:
	pass

func _physics_process(dt: float) -> void:
	move(dt)

func move(dt: float) -> void:
	# Forward Movement
	apply_impulse(Vector2.UP.rotated(rotation) * MOVE_SCALER * Input.get_action_strength("forward"))
	
	# Rotation Movement
	rotation += Input.get_axis("right", "left") * ROTATE_SPEED * dt
