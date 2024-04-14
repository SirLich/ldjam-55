extends Control

var count = 0
var can_exit = false

func _ready():
	Bus.game_over.connect(on_game_over)
	Bus.enemy_turn_ended.connect(on_enemy_turn_ended)

func on_enemy_turn_ended():
	count += 1
	$Label.text = "SURVIVED: " + str(count)
	
func on_game_over():
	visible = true
	await get_tree().create_timer(2).timeout
	can_exit = true

func _input(event):
	if (event is InputEventMouseButton or event is InputEventKey) and can_exit:
		do_change()

func do_change():
	var tween = get_tree().create_tween()
	tween.tween_property(get_parent().get_parent(), "modulate", Color.BLACK, 1)
	await tween.finished
	get_tree().change_scene_to_file("res://main_menu.tscn")
