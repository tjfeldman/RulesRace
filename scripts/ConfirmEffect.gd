extends Container
@onready var label: Label = $PanelContainer/MarginContainer/VBoxContainer/Label

signal choice_choosen(choice: bool);

func setLabel(text: String):
	label.text = text;

func _on_yes_pressed() -> void:
	queue_free();
	choice_choosen.emit(true);
	#Events.emit_signal("confirm_rule_effect", _affectedPlayer, true);

func _on_no_pressed() -> void:
	queue_free();
	choice_choosen.emit(false);
	#Events.emit_signal("confirm_rule_effect", _affectedPlayer, false);
