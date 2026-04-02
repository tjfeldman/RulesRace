extends Container
class_name OfficeChoice

enum Option {
	TICKET,
	DIE,
	RULE,
	NONE = -1,
};

signal choice_selected(choice: Option);

func _on_ticket_button_pressed() -> void:
	queue_free();
	choice_selected.emit(Option.TICKET);

func _on_die_button_pressed() -> void:
	queue_free();
	choice_selected.emit(Option.DIE);

func _on_rule_button_pressed() -> void:
	queue_free();
	choice_selected.emit(Option.RULE);
