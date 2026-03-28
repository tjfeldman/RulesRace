extends Control

@onready var group_rule_selector: CenterContainer = $GroupRuleSelector
@onready var whenLabel: Label = $WhenDisplay/Label
@onready var triggerLabel: Label = $TriggerDisplay/Label
@onready var effectLabel: Label = $EffectDisplay/Label

#set to -1 to represent None
var _whenRule: GroupRules.When = GroupRules.When.NONE;
var _triggerRule: GroupRules.Trigger = GroupRules.Trigger.NONE;
var _effectRule: GroupRules.Effect = GroupRules.Effect.NONE;

var _canRules = [GroupRules.Trigger.ROLL_PRISON, GroupRules.Trigger.ROLL_ONE, GroupRules.Trigger.ROLL_TWO, GroupRules.Trigger.ROLL_THREE, GroupRules.Trigger.MOVES_PRISON];
var _targetsAnotherPlayer = [GroupRules.Effect.TRANSFER_TICKET, GroupRules.Effect.SEND_PLAYER_BACK_ONE];

func _ready() -> void:
	group_rule_selector.visible = false;
	group_rule_selector.rules_updated.connect(_on_rules_updated);
	
"""
PUBLIC ACCESSIBLE FUNCTIONS
"""
func trigger_event(pair: EventPair, _turnPlayer: Player):
	match pair.action:
		EventPair.ActionChecks.JAIL:
			#Prison action triggers on moving to Prison when it is a player in Prison
			if _triggerRule == GroupRules.Trigger.MOVES_PRISON and _whenRule == GroupRules.When.PRISON:
				await _prompt_all_prisoners(pair.player);
				

func prompt_group_rule_change_for_player(player: Player):
	if player.isBot():
		group_rule_selector.random_rule();
	else:
		group_rule_selector.set_for_editing();
		
func trigger_effect_for_player(player: Player):
	if _effectRule in _targetsAnotherPlayer:
		await _target_effect(player);
	else:
		await _trigger_effect(player);
		
func check_roll_trigger(turn_player: Player, roll: Variant):
	#if the when condition is not met or player is in jail
	#then we return false
	if not GroupRules.verify_when(turn_player, _whenRule) or turn_player.isInJail():
		return false;
		
	match [_triggerRule, roll]:
		[GroupRules.Trigger.ROLL_PRISON, "Jail"]:
			#DO NOT GO TO JAIL AND CAN USE EFFECT
			if GroupRules.verify_player_can_use_rule(turn_player, _effectRule):
				await trigger_effect_for_player(turn_player);
			return true;
		[GroupRules.Trigger.ROLL_ONE, 1]:
			#MOVE PLAYER FORWARD 1 AND CAN USE EFFECT
			await turn_player.movePlayerXSpaces(1);
			if GroupRules.verify_player_can_use_rule(turn_player, _effectRule):
				await trigger_effect_for_player(turn_player);
			return true;
		[GroupRules.Trigger.ROLL_TWO, 2]:
			#MOVE PLAYER FORWARD 2 AND CAN USE EFFECT
			await turn_player.movePlayerXSpaces(2);
			if GroupRules.verify_player_can_use_rule(turn_player, _effectRule):
				await trigger_effect_for_player(turn_player);
			return true;
		[GroupRules.Trigger.ROLL_THREE, 3]:
			#MOVE PLAYER FORWARD 3 AND CAN USE EFFECT
			await turn_player.movePlayerXSpaces(3);
			if GroupRules.verify_player_can_use_rule(turn_player, _effectRule): 
				await trigger_effect_for_player(turn_player);
			return true;
		_:
			return false;
	
"""
PRIVATE FUNCTIONS
"""
func _on_background_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_click") and not group_rule_selector.isEditing():
		group_rule_selector.visible = !group_rule_selector.visible;
		
func _on_rules_updated(_whenRuleBtn: RuleButton, _triggerRuleBtn: RuleButton, _effectRuleBtn: RuleButton):
	whenLabel.text = _whenRuleBtn.description;
	triggerLabel.text = _triggerRuleBtn.description;
	effectLabel.text = _effectRuleBtn.description;
	
	_whenRule = _whenRuleBtn.type;
	_triggerRule = _triggerRuleBtn.type;
	_effectRule = _effectRuleBtn.type;

func _trigger_effect(affectedPlayer: Player):
	#if the rule can be used, asked the player if they want to use it
	if _triggerRule in _canRules:
		#exit if they decline
		if await affectedPlayer.confirmGroupEffect(): return;
	match _effectRule:
		GroupRules.Effect.MOVE_ONE:
			await affectedPlayer.movePlayerXSpaces(1);
		GroupRules.Effect.GAIN_TICKET:
			affectedPlayer.addEscapeTicket();
		GroupRules.Effect.REROLL_DIE:
			await Events.emit_signal("gain_die_roll", false);
		GroupRules.Effect.ROLL_SPECIAL_DIE:
			await Events.emit_signal("gain_die_roll", true);
		GroupRules.Effect.MOVE_TO_PLAYER_AHEAD:
			await affectedPlayer.moveToPlayer(PlayerManager.getPlayerAhead(affectedPlayer));
		GroupRules.Effect.MOVE_BACK:
			await affectedPlayer.movePlayerXSpaces(-1);
				
func _target_effect(affectedPlayer: Player):
	#we can't move players who are at the start or are currently in jail
	var playerlist = PlayerManager.getListOfAllOtherPlayers(affectedPlayer);
	var is_can_rule = _triggerRule in _canRules;
	match _effectRule:
		GroupRules.Effect.SEND_PLAYER_BACK_ONE:
			#can't move players who are at start or currently in jail
			playerlist.filter(func(p): return p.getBoardPosition() > 0 and not p.isInJail());
			var target = await affectedPlayer.selectTargetPlayer(playerlist, is_can_rule);
			if not target: return;	#if no target is selected, exit
			await target.movePlayerXSpaces(-1);
		GroupRules.Effect.TRANSFER_TICKET:
			var target = await affectedPlayer.selectTargetPlayer(playerlist, is_can_rule);
			if not target: return;	#if no target is selected, exit
			affectedPlayer.removeEscapeTicket();
			target.addEscapeTicket();
	
func _prompt_all_prisoners(triggerPlayer: Player):
	var prisoners = PlayerManager.getPrisonPlayers();
	for prisoner in prisoners:
		if prisoner != triggerPlayer:
			await trigger_effect_for_player(prisoner);
	
