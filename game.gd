extends Node2D

@export var turn_timer : Timer
@export var end_turn_button : Button



@export var turn_time = 1

func _on_end_turn_button_pressed():
	end_turn_button.visible = false
	turn_timer.start(turn_time)
	Bus.enemy_turn_started.emit(turn_time)
	
func _on_enemy_turn_timer_timeout():
	end_turn_button.visible = true
	print("STOP")
	Bus.enemy_turn_ended.emit()
