extends "res://scripts/Player/PlayerCharacter.gd"
class_name HumanPlayer

@onready var action_ui: Actions = $"../../ActionUI"

func setActionOptions(options: Dictionary[Actions.Type, Callable]):
	print("In Human Player");
	action_ui.setActionOptions(options);

func selectOfficeReward():
	print("Selecting Office Reward");
	return await action_ui.select_office_reward();
