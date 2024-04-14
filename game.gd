extends Node2D

@export var turn_timer : Timer
@export var end_turn_button : Button

@export var turn_time = 1

var turns = 0
func _on_end_turn_button_pressed():
	$ArrowSprite.visible = false
	end_turn_button.visible = false
	turn_timer.start(turn_time)
	Bus.enemy_turn_started.emit(turn_time)
	turns += 1
	if turns > 50 and get_tree().get_nodes_in_group("enemy").size() == 0:
		get_tree().change_scene_to_file("res://win.tscn")
	
func _on_enemy_turn_timer_timeout():
	end_turn_button.visible = true
	Bus.enemy_turn_ended.emit()
	
func _input(event):
	if event.is_action_released("kill_all"):
		get_tree().call_group("enemy", "queue_free")
