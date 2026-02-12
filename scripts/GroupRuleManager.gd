extends Control

@onready var group_rule_selector: CenterContainer = $GroupRuleSelector
@onready var whenLabel: Label = $WhenDisplay/Label
@onready var triggerLabel: Label = $TriggerDisplay/Label
@onready var effectLabel: Label = $EffectDisplay/Label

#set to -1 to represent None
var whenRule: GroupRules.When = GroupRules.When.NONE;
var triggerRule: GroupRules.Trigger = GroupRules.Trigger.NONE;
var effectRule: GroupRules.Effect = GroupRules.Effect.NONE;

var canRules = [GroupRules.Trigger.ROLL_PRISON, GroupRules.Trigger.ROLL_ONE, GroupRules.Trigger.ROLL_TWO, GroupRules.Trigger.ROLL_THREE, GroupRules.Trigger.MOVES_PRISON]
var targetsAnotherPlayer = [GroupRules.Effect.TRANSFER_TICKET, GroupRules.Effect.SEND_PLAYER_BACK_ONE]

const LABEL_TEXT = {
	GroupRules.Effect.MOVE_ONE: "Would you like to move 1 space forward?",
	GroupRules.Effect.GAIN_TICKET: "Would you like to gain 1 Escape Ticket?",
	GroupRules.Effect.REROLL_DIE: "Would you like to roll the die again?",
	GroupRules.Effect.ROLL_SPECIAL_DIE: "Would you like to roll the special die?",
	GroupRules.Effect.MOVE_TO_PLAYER_AHEAD: "Would you like to move to the player ahead?",
	GroupRules.Effect.MOVE_BACK: "Would you like to move back 1 space?",
	GroupRules.Effect.SEND_PLAYER_BACK_ONE: "Pick player to move back 1 space",
	GroupRules.Effect.TRANSFER_TICKET: "Pick player to transfer an escape ticket to",
}

#TODO: Maybe change to Static Class

func _ready() -> void:
	group_rule_selector.visible = false;
	group_rule_selector.rules_updated.connect(_on_rules_updated);
	Events.perform_rule_effect.connect(_useEffect);
	
func _on_background_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_click"):
		group_rule_selector.visible = !group_rule_selector.visible;
		
func _on_rules_updated(whenRuleBtn: RuleButton, triggerRuleBtn: RuleButton, effectRuleBtn: RuleButton):
	whenLabel.text = whenRuleBtn.description;
	triggerLabel.text = triggerRuleBtn.description;
	effectLabel.text = effectRuleBtn.description;
	
	whenRule = whenRuleBtn.type;
	triggerRule = triggerRuleBtn.type;
	effectRule = effectRuleBtn.type;
	
	#after we update the display, we must know create a group action object to emit back
	var groupAction = GroupAction.new(triggerRule, effectRule);
	Events.emit_signal("update_group_action", groupAction);

func _trigger_effect(affectedPlayer: Player):
	#if the rule can be used, asked the player if they want to use it
	if triggerRule in canRules and not affectedPlayer.isBot():
		#exit if they decline
		if not await _promptForEffect(): return;
	match effectRule:
		GroupRules.Effect.MOVE_ONE:
			await affectedPlayer.movePlayerXSpaces(1);
		GroupRules.Effect.GAIN_TICKET:
			affectedPlayer.addEscapeTicket();
		GroupRules.Effect.REROLL_DIE:
			Events.emit_signal("gain_die_roll", false);
		GroupRules.Effect.ROLL_SPECIAL_DIE:
			Events.emit_signal("gain_die_roll", true);
		GroupRules.Effect.MOVE_TO_PLAYER_AHEAD:
			await affectedPlayer.moveToPlayer(PlayerManager.getPlayerAhead(affectedPlayer));
		GroupRules.Effect.MOVE_BACK:
			await affectedPlayer.movePlayerXSpaces(-1);
				
func _target_effect(affectedPlayer: Player):
	#we can't move players who are at the start or are currently in jail
	var playerList = PlayerManager.getListOfAllOtherPlayers(affectedPlayer);
	var target : Player = null;		
	match effectRule:
		GroupRules.Effect.SEND_PLAYER_BACK_ONE:
			#can't move players who are at start or currently in jail
			playerList.filter(func(p): return p.getBoardPosition() > 0 and not p.isInJail());
			if affectedPlayer.isBot():
				target = playerList.pick_random();
			else:
				target = await _promptTargetEffect(playerList);
			if not target: return;	#if no target is selected, exit
			await target.movePlayerXSpaces(-1);
		GroupRules.Effect.TRANSFER_TICKET:
			if affectedPlayer.isBot():
				target = playerList.pick_random();
			else:
				target = await _promptTargetEffect(playerList);
			if not target: return;	#if no target is selected, exit
			affectedPlayer.removeEscapeTicket();
			target.addEscapeTicket();
			
func checkRollTrigger(player: Player, roll: Variant):
	match [triggerRule, roll]:
		[GroupRules.Trigger.ROLL_PRISON, "Jail"]:
			#DO NOT GO TO JAIL AND CAN USE EFFECT
			if GroupRules.verify_player_can_use_rule(player, effectRule):
				await _useEffect(player);
			return true;
		[GroupRules.Trigger.ROLL_ONE, 1]:
			#MOVE PLAYER FORWARD 1 AND CAN USE EFFECT
			await player.movePlayerXSpaces(1);
			if GroupRules.verify_player_can_use_rule(player, effectRule):
				await _useEffect(player);
			return true;
		[GroupRules.Trigger.ROLL_TWO, 2]:
			#MOVE PLAYER FORWARD 2 AND CAN USE EFFECT
			await player.movePlayerXSpaces(2);
			if GroupRules.verify_player_can_use_rule(player, effectRule):
				await _useEffect(player);
			return true;
		[GroupRules.Trigger.ROLL_THREE, 3]:
			#MOVE PLAYER FORWARD 3 AND CAN USE EFFECT
			await player.movePlayerXSpaces(3);
			if GroupRules.verify_player_can_use_rule(player, effectRule): 
				await _useEffect(player);
			return true;
		_:
			return false;
			
func _useEffect(player: Player):
	if effectRule in targetsAnotherPlayer:
		await _target_effect(player);
	else:
		await _trigger_effect(player);
	Events.emit_signal("group_rule_finished");

#prompts the player who triggered the rule if they want to use the effect
func _promptForEffect():		
	var confirmBox = preload("res://scenes/confirmRuleUsage.tscn");
	var confirm = confirmBox.instantiate();
	var scene = get_tree().current_scene;
	scene.add_child(confirm);
	confirm.setLabel(LABEL_TEXT[effectRule]);
	return confirm.choice_choosen;
		
#prompt the player who they want to target
func _promptTargetEffect(targetList: Array[Player]):
	var selectPrompt = preload("res://scenes/selectPlayerPrompt.tscn");
	var prompt = selectPrompt.instantiate();
	var scene = get_tree().current_scene;
	scene.add_child(prompt);
	prompt.setLabel(LABEL_TEXT[effectRule]);
	prompt.setPlayerList(targetList, triggerRule in canRules);
	return await prompt.selected_player;
