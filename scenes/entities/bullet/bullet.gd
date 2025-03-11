extends RigidBody2D

func _on_body_entered(_body: Node) -> void:
	queue_free()

func _on_lifespan_timer_timeout() -> void:
	queue_free()
