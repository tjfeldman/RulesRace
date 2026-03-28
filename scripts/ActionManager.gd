extends Control
class_name Actions

@onready var action_buttons: VBoxContainer = $PanelContainer/MarginContainer/ActionButtons

enum Type {
	DIE,
	SPECIAL,
	TICKET,
	GROUP,
	END
};

func _ready() -> void:
	#connect button event to send itself
	for action_button in action_buttons.get_children():
		action_button.pressed.connect(_on_action_btn_pressed.bind(action_button));
	
"""
Functions to Handle Turn Actions
"""
func setActionOptions(options: Dictionary[Actions.Type, Callable]):
	self.visible = true;
	_clear_buttons();
	
	for action_button in action_buttons.get_children():
		var action = action_button.action_type;
		action_button.setButton(options.get(action));
	
func _clear_buttons():
	for action_button in action_buttons.get_children():
		action_button.clearButton();
		
func _on_action_btn_pressed(button):
	_disable_all_actions();
	if button.action_type == Type.END:
		self.visible = false;
	button.action();
	
func _disable_all_actions():
	for action_button in action_buttons.get_children():
		action_button.disabled = true;
	
func _enable_all_actions():
	for action_button in action_buttons.get_children():
		action_button.disabled = false;
		
"""
Functions for Prompts
"""
func select_office_reward():
	var officeChoiceBox = preload("res://scenes/officeChoice.tscn");
	var choiceBox = officeChoiceBox.instantiate();
	var scene = get_tree().current_scene.get_parent();
	print(scene);
	scene.add_child(choiceBox);
	return await choiceBox.choice_selected;
