@tool

extends VBoxContainer

@export var action : String
@export var title : String
@export var need_charges : int

var charges : int

@export var button : Button

func _ready():
	charges = need_charges
	Bus.perform_action.connect(on_action_performed)

func on_action_performed(in_action):
	pass
	if Player.PlayerAction.get(action) == in_action:
		print("OK OK OK ")
	
func _process(delta):
	button.text = title
	
func _on_move_button_pressed():
	get_tree().get_first_node_in_group("player").set_action(action)
