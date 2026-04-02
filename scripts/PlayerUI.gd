extends Control

#TODO: Each player should have control of their own UI instead of relying on events

@onready var leading: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Leading
@onready var player_name: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PlayerName
@onready var ticket_counter: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/TicketCounter
@onready var count: Label = $PanelContainer/MarginContainer/VBoxContainer/TicketCounter/Count
@onready var finished: Label = $PanelContainer/MarginContainer/VBoxContainer/Finished
@onready var trigger: Label = $PanelContainer/MarginContainer/VBoxContainer/PersonalRule/Trigger
@onready var condition: Label = $PanelContainer/MarginContainer/VBoxContainer/PersonalRule/Condition
@onready var target: Label = $PanelContainer/MarginContainer/VBoxContainer/PersonalRule/Target
@onready var effect: Label = $PanelContainer/MarginContainer/VBoxContainer/PersonalRule/Effect

#only allow set player to be assigned once
var assignedPlayer : Player:
	set(value):
		if assignedPlayer == null:
			assignedPlayer = value;
			
func _ready() -> void:
	update_ui();
	player_name.text = assignedPlayer.playerName;
	Events.updated_escape_tickets.connect(_on_player_ticket_count_update);
	Events.player_moved.connect(_update_leading);
	Events.player_reached_goal.connect(_on_player_finished);
	Events.game_over.connect(_game_is_over);
	
	var personal_rule = assignedPlayer.getPersonalRule();
	trigger.text = PersonalRules.get_trigger_str(personal_rule.get_trigger());
	condition.text = PersonalRules.get_condition_str(personal_rule.get_condition());
	target.text = PersonalRules.get_target_str(personal_rule.get_target());
	effect.text = PersonalRules.get_effect_str(personal_rule.get_effect());
			
func update_ui():
	count.text = str(assignedPlayer.getEscapeTicketCount());

func _on_player_ticket_count_update(player: Player):
	#only call update when the assigned player is updated
	if player == assignedPlayer:
		update_ui();
		
func _update_leading():
	var leading_player = PlayerManager.getLeadingPlayer();
	if leading_player == assignedPlayer:
		leading.visible = true;
	else:
		leading.visible = false;

func _on_player_finished(player: Player):
	if player == assignedPlayer:
		var place = PlayerManager.getPlayerFinishedPlace(player);
		match place:
			1:
				finished.text = "FINISHED: 1st Place";
			2:
				finished.text = "FINISHED: 2nd Place";
			3:
				finished.text = "FINISHED: 3rd Place";
			_:
				finished.text = "FINISHED: %sth Place"%place;
		ticket_counter.visible = false;
		finished.visible = true;		

func _game_is_over():
	if !finished.visible:
		_on_player_finished(assignedPlayer);
