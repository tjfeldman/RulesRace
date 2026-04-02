extends "res://scripts/Player/PlayerCharacter.gd"
class_name HumanPlayer

@onready var action_ui: Actions = $"../../ActionUI"

func setActionOptions(options: Dictionary[Actions.Type, Callable]):
	action_ui.setActionOptions(options);

func selectOfficeReward():
	return await action_ui.select_office_reward();
	
func confirmGroupEffect():
	return await action_ui.confirm_group_rule_use();
	
func acknowledgePersonalRule(events: Array[PersonalRuleAction]):
	await action_ui.acknowledge_personal_rule(events);

func selectTargetPlayer(playerlist: Array[Player], is_can_rule):
	return await action_ui.select_target_for_effect(playerlist, is_can_rule);
