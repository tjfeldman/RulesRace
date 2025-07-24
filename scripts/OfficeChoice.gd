extends Container

func _on_ticket_button_pressed() -> void:
	queue_free();
	Events.emit_signal("office_choice_selected", Events.OfficeChoice.Ticket);

func _on_die_button_pressed() -> void:
	queue_free();
	Events.emit_signal("office_choice_selected", Events.OfficeChoice.Dice);

func _on_rule_button_pressed() -> void:
	queue_free();
	Events.emit_signal("office_choice_selected", Events.OfficeChoice.Rule);
