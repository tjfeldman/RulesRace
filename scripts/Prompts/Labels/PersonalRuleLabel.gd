extends Node

@onready var player: Label = $PanelContainer/MarginContainer/Event/Player
@onready var effect: Label = $PanelContainer/MarginContainer/Event/Effect

func set_event(action: PersonalRuleAction):
	player.text = action.get_player().playerName;
	effect.text = "%s %s"%[action.get_target().playerName, action.get_description()];
