extends Label


var turns = 50

func _ready():
	Bus.enemy_turn_started.connect(on_enemy_turn_started)

func on_enemy_turn_started(time):
	turns -= 1
	if turns >= 0:
		text = "Waves remaining: " + str(turns)
	else:
		text = "Clear remaining enemies"
