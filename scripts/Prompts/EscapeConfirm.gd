extends Container

func _on_yes_pressed() -> void:
	queue_free();
	Events.emit_signal("escape_jail_with_ticket", true);

func _on_no_pressed() -> void:
	queue_free();
	Events.emit_signal("escape_jail_with_ticket", false);
