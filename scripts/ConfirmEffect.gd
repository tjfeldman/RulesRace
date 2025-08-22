extends Container
@onready var label: Label = $PanelContainer/MarginContainer/VBoxContainer/Label

var _affectedPlayer: Player;

func setAffectedPlayer(player: Player):
	_affectedPlayer = player;

func setLabel(text: String):
	label.text = text;

func _on_yes_pressed() -> void:
	queue_free();
	Events.emit_signal("confirm_rule_effect", _affectedPlayer, true);

func _on_no_pressed() -> void:
	queue_free();
	Events.emit_signal("confirm_rule_effect", _affectedPlayer, false);
