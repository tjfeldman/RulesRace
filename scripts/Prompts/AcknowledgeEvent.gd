extends Node

@onready var personal_rule_events: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/PersonalRuleEvents

signal acknowledged();

func create_event_labels(events: Array[PersonalRuleAction]):
	for event in events:
		var label = PromptManager.get_personal_rule_label();
		personal_rule_events.add_child(label);
		label.set_event(event);

func _on_ok_pressed() -> void:
	queue_free();
	acknowledged.emit();
