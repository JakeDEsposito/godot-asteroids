extends Control

@onready var score_ui: Label = %Score
@onready var lives_ui: Label = %Lives

func set_score(score: int) -> void:
	score_ui.text = str(score).lpad(4, "0")

func set_lives(lives: int) -> void:
	lives_ui.text = "♡".repeat(lives)
