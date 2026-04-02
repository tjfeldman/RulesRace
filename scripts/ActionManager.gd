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
	Events.player_reached_goal.connect(_player_has_finished);
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
		
func _player_has_finished(player: Player):
	if player == get_tree().current_scene.get_turn_player():
		self.visible = false;
"""
Functions for Prompts
"""
func _get_scene():
	return get_tree().current_scene.get_parent();

func select_office_reward():
	var officeChoiceBox = preload("res://scenes/officeChoice.tscn");
	var choiceBox = officeChoiceBox.instantiate();
	var scene = _get_scene();
	scene.add_child(choiceBox);
	return await choiceBox.choice_selected;
	
#prompts the player who triggered the rule if they want to use the effect
func confirm_group_rule_use():		
	var confirmBox = preload("res://scenes/confirmRuleUsage.tscn");
	var confirm = confirmBox.instantiate();
	var scene = _get_scene();
	scene.add_child(confirm);
	confirm.setLabel(GroupRules.get_effect_label());
	var cost = GroupRules.get_cost_string();
	if cost: confirm.setCostLabel(cost);
	return await confirm.choice_choosen;

#prompt the player who they want to target
func select_target_for_effect(targetList: Array[Player], is_can_rule):
	var selectPrompt = preload("res://scenes/selectPlayerPrompt.tscn");
	var prompt = selectPrompt.instantiate();
	var scene = _get_scene();
	scene.add_child(prompt);
	prompt.setLabel(GroupRules.get_effect_label());
	prompt.setPlayerList(targetList, is_can_rule);
	return await prompt.selected_player;
