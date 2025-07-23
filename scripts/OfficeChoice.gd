extends CenterContainer


func _on_ticket_button_pressed() -> void:
	print("Player earns 1 ticket");
	queue_free();	

func _on_die_button_pressed() -> void:
	print("Player rolls special die");
	queue_free();

func _on_rule_button_pressed() -> void:
	print("Player changes group rule");
	queue_free();
