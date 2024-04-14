extends Node

signal enemy_turn_started(float)
signal enemy_turn_ended

signal perform_action(action)

signal recharge_all

signal player_turn_started
signal player_turn_ended

func _input(event):
	if event.is_action_released("cheat_fill"):
		recharge_all.emit()
