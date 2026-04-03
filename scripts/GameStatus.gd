extends Node

@onready var text_field: RichTextLabel = $PanelContainer/TextField

func _ready() -> void:
	Events.update_game_status.connect(_update_game_status);

func _update_game_status(info: String):
	text_field.append_text(info);
	text_field.newline();
