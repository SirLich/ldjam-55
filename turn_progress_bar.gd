extends ProgressBar

var countdown = false 

func _ready():
	Bus.enemy_turn_ended.connect(on_enemy_turn_ended)
	Bus.enemy_turn_started.connect(on_enemy_turn_started)

func on_enemy_turn_started(time):
	max_value = time * 100
	value = max_value
	countdown = true
	
func on_enemy_turn_ended():
	value = 0
	countdown = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if countdown:
		value -= delta * 100
