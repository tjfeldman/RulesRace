extends Node2D

@onready var board : Node2D = $Board;
@onready var dice : Sprite2D = $Dice;
@onready var special_dice: Sprite2D = $SpecialDice
@onready var hud: CanvasLayer = $HUD
@onready var group_rule_manager: Control = $GroupRuleManager
@onready var action_ui: ActionManager = $ActionUI
#TODO: Send turn_status label to other Managers so they can update the status too
@onready var turn_status: Label = $TurnStatus

func _ready() -> void:
	Events.end_turn.connect(_on_turn_end);
	Events.roll_die_action.connect(_die_rolling);
	Events.escape_jail_action.connect(_used_escape_ticket);
	Events.player_reached_goal.connect(_player_finished);
	
	#start game
	call_deferred("_start_game");
	
func _start_game():
	#add UI to HUD
	var offset = 0;
	for player in PlayerManager.getPlayers():
		var playerUI = preload("res://scenes/playerUI.tscn");
		var ui = playerUI.instantiate();
		ui.assignedPlayer = player;
		hud.add_child(ui);
		ui.position += Vector2(0, offset);
		offset+= ui.size.y + 16;
	
	turn_status.text = "%s's Turn" % PlayerManager.getCurrentTurnPlayer().playerName;
	Events.emit_signal("start_turn");
		
func _prompt_for_office_reward(player: Player):
	var picked;
	if !player.isBot():
		var officeChoiceBox = preload("res://scenes/officeChoice.tscn");
		var choiceBox = officeChoiceBox.instantiate();
		add_child(choiceBox);
		picked = await choiceBox.choice_selected;
	else:
		#TODO Right now there is no mechanic to change group rule so bot can't chose it right now
		var choices: Array[OfficeChoice.Option] = [OfficeChoice.Option.TICKET, OfficeChoice.Option.DIE];
		picked = choices.pick_random();
		
	match picked:
		OfficeChoice.Option.TICKET:
			turn_status.text = "%s recieved an escape ticket" % player.playerName;
			player.addEscapeTicket();
		OfficeChoice.Option.DIE:
			turn_status.text = "%s can roll the special die" % player.playerName;
			Events.emit_signal("gain_die_roll", true);
	
func _on_dice_has_rolled(_type: Dice.Type, roll: Variant) -> void:	
	var currentPlayer = PlayerManager.getCurrentTurnPlayer();
	if await group_rule_manager.checkRollTrigger(currentPlayer, roll):
		turn_status.text = "%s triggered the group rule" %currentPlayer.playerName;
		Events.emit_signal("die_rolled");
		return;
		
	match roll:
		"Jail":
			var sentToJail = await currentPlayer.sendToJail();
			if sentToJail:
				turn_status.text = "%s went to jail" %currentPlayer.playerName;
		"Escape":
			var escapeFromJail = await currentPlayer.escapeFromJail();
			if escapeFromJail:
				turn_status.text = "%s escaped jail" %currentPlayer.playerName;
		_:
			if !currentPlayer.isInJail():
				turn_status.text = "%s is moving %s spaces" %[currentPlayer.playerName, roll];
				await currentPlayer.movePlayerXSpaces(roll);
				#if player moves onto office space via roll, then they can pick an office space reward
				if board.isOfficeSpace(currentPlayer.getBoardPosition()):
					turn_status.text = "%s landed on office" %currentPlayer.playerName;
					await _prompt_for_office_reward(currentPlayer);
	Events.emit_signal("die_rolled");
			

#TODO: Factor for more than 2 players
func _player_finished(player: Player):
	action_ui.playerFinished();
	turn_status.text = "%s reached the goal" %player.playerName;

func _on_turn_end():
	if ActionManager.getCurrentTurnState() != ActionManager.TurnState.OVER:
		PlayerManager.nextTurn();
		turn_status.text = "%s's Turn" % PlayerManager.getCurrentTurnPlayer().playerName;
	
#For Status Update
func _die_rolling(special: bool):
	var dieName = "the special die" if special else "the die";
	turn_status.text = "%s is rolling %s" %[PlayerManager.getCurrentTurnPlayer().playerName, dieName];
			
func _used_escape_ticket():
	turn_status.text = "%s used an escape ticket to leave jail" % PlayerManager.getCurrentTurnPlayer().playerName;
	
