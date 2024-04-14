extends Control

@onready var press_key = $PressKey

# Called when the node enters the scene tree for the first time.
func _ready():
	press_key.visible = false

func _on_timer_timeout():
	press_key.visible = true

func _input(event):
	if (event is InputEventMouseButton or event is InputEventKey) and press_key.visible:
		do_change()

func do_change():
	press_key.visible = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.BLACK, 1)
	await tween.finished
	get_tree().change_scene_to_file("res://game.tscn")
