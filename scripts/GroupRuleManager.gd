extends Control
class_name GroupRules

enum When {
	TURN,
	PRISON,
	LEADING,
	NONE
}

enum Trigger {
	ROLL_PRISON,
	ROLL_ONE,
	ROLL_TWO,
	ROLL_THREE,
	MOVES_PRISON,
	MOVE_BACK_TWO,
	DISCARD_TICKET,
	FORFEIT_DIE,
	NONE
}

enum Effect {
	MOVE_ONE,
	GAIN_TICKET,
	TRANSFER_TICKET,
	REROLL_DIE,
	MOVE_TO_PLAYER_AHEAD,
	MOVE_BACK,
	ROLL_SPECIAL_DIE,
	SEND_PLAYER_BACK_ONE,
	NONE
}

const LABEL_TEXT = {
	Effect.MOVE_ONE: "Would you like to move 1 space forward?",
	Effect.GAIN_TICKET: "Would you like to gain 1 Escape Ticket?",
	Effect.REROLL_DIE: "Would you like to roll the die again?",
	Effect.ROLL_SPECIAL_DIE: "Would you like to roll the special die?",
	Effect.MOVE_TO_PLAYER_AHEAD: "Would you like to move to the player ahead?",
	Effect.MOVE_BACK: "Would you like to move back 1 space?",
	Effect.SEND_PLAYER_BACK_ONE: "Pick player to move back 1 space",
	Effect.TRANSFER_TICKET: "Pick player to transfer an escape ticket to",
}

const BENEFICIAL_EFFECTS: Array[Effect] = [Effect.MOVE_ONE, Effect.GAIN_TICKET, Effect.REROLL_DIE,\
										Effect.MOVE_TO_PLAYER_AHEAD, Effect.ROLL_SPECIAL_DIE, Effect.SEND_PLAYER_BACK_ONE];
const HARMFUL_EFFECTS: Array[Effect] = [Effect.SEND_PLAYER_BACK_ONE];

@onready var group_rule_selector: CenterContainer = $GroupRuleSelector
@onready var whenLabel: Label = $WhenDisplay/Label
@onready var triggerLabel: Label = $TriggerDisplay/Label
@onready var effectLabel: Label = $EffectDisplay/Label

#set to -1 to represent None
static var _whenRule: GroupRules.When = GroupRules.When.NONE;
static var _triggerRule: GroupRules.Trigger = GroupRules.Trigger.NONE;
static var _effectRule: GroupRules.Effect = GroupRules.Effect.NONE;
#public getters
static func get_when(): return _whenRule;
static func get_trigger(): return _triggerRule;
static func get_effect(): return _effectRule;

var _canRules = [GroupRules.Trigger.ROLL_PRISON, GroupRules.Trigger.ROLL_ONE, GroupRules.Trigger.ROLL_TWO, \
				GroupRules.Trigger.ROLL_THREE, GroupRules.Trigger.MOVES_PRISON];
var _targetsAnotherPlayer = [GroupRules.Effect.TRANSFER_TICKET, GroupRules.Effect.SEND_PLAYER_BACK_ONE];

func _ready() -> void:
	group_rule_selector.visible = false;
	group_rule_selector.rules_updated.connect(_on_rules_updated);
	
"""
STATIC FUNCTIONS
"""
static func is_group_rule_active(): 
	return _whenRule != When.NONE and _triggerRule != Trigger.NONE and _effectRule != Effect.NONE;
	
static func get_effect_label(): 
	return LABEL_TEXT[_effectRule];

static func get_cost_string():
	match _triggerRule:
		Trigger.MOVE_BACK_TWO:
			return "(-2 Spaces)";
		Trigger.DISCARD_TICKET:
			return "(-1 Ticket)";
		Trigger.FORFEIT_DIE:
			return "(Forfeit Roll)";
		_:
			return null;
	
"""
VERIFY FUNCTIONS
"""
#checks if the player triggering a rule can activate the rule
func _verify_when(triggering_player: Player):
	match _whenRule:
		When.TURN:
			return TurnManager.get_turn_player() == triggering_player;
		When.PRISON:
			return triggering_player.isInJail();
		When.LEADING:
			return PlayerManager.getLeadingPlayer() == triggering_player;
		_:
			return false;
	
func _verify_player_can_use_rule(affectedPlayer: Player):
	#if player has made it to the goal, they cannot benefit from the effect
	if affectedPlayer.hasFinished(): return false;
	
	match _effectRule:
		Effect.MOVE_ONE:
			return !affectedPlayer.isInJail();
		Effect.MOVE_TO_PLAYER_AHEAD:
			return !affectedPlayer.isInJail() and PlayerManager.getPlayerAhead(affectedPlayer);
		Effect.MOVE_BACK:
			return !affectedPlayer.isInJail() and affectedPlayer.getBoardPosition() > 0;
		Effect.SEND_PLAYER_BACK_ONE:
			#we can't move players who are at the start, are currently in jail, or has finished the race
			return PlayerManager.getListOfAllOtherPlayers(affectedPlayer).filter(func(p): return p.getBoardPosition() > 0 and not p.isInJail() and not p.hasFinished());
		Effect.TRANSFER_TICKET:
			return affectedPlayer.hasEscapeTicket();
		Effect.REROLL_DIE, Effect.ROLL_SPECIAL_DIE:
			#dice can only be used on player's turn
			return TurnManager.get_turn_player() == affectedPlayer;
		_:
			return true;
	
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
	if not _verify_when(turn_player) or turn_player.isInJail():
		return false;
		
	match [_triggerRule, roll]:
		[GroupRules.Trigger.ROLL_PRISON, "Jail"]:
			#DO NOT GO TO JAIL AND CAN USE EFFECT
			if _verify_player_can_use_rule(turn_player):
				await trigger_effect_for_player(turn_player);
			return true;
		[GroupRules.Trigger.ROLL_ONE, 1]:
			#MOVE PLAYER FORWARD 1 AND CAN USE EFFECT
			await turn_player.movePlayerXSpaces(1);
			if _verify_player_can_use_rule(turn_player):
				await trigger_effect_for_player(turn_player);
			return true;
		[GroupRules.Trigger.ROLL_TWO, 2]:
			#MOVE PLAYER FORWARD 2 AND CAN USE EFFECT
			await turn_player.movePlayerXSpaces(2);
			if _verify_player_can_use_rule(turn_player):
				await trigger_effect_for_player(turn_player);
			return true;
		[GroupRules.Trigger.ROLL_THREE, 3]:
			#MOVE PLAYER FORWARD 3 AND CAN USE EFFECT
			await turn_player.movePlayerXSpaces(3);
			if _verify_player_can_use_rule(turn_player): 
				await trigger_effect_for_player(turn_player);
			return true;
		_:
			return false;
	#END MATCH

func can_pay(player: Player, hasNormalDie):
	var canActivate = _verify_when(player);
	if canActivate and _verify_player_can_use_rule(player):
		match _triggerRule:
			Trigger.MOVE_BACK_TWO:
				return !player.isInJail() and player.getBoardPosition() >= 2;
			Trigger.DISCARD_TICKET:
				return player.getEscapeTicketCount() >= (2 if _effectRule == Effect.TRANSFER_TICKET else 1);
			Trigger.FORFEIT_DIE:
				return hasNormalDie;
		#END MATCH
	return false; #If cannot activate or not a proper trigger, return false
	
func pay_cost_for_player(player: Player):
	match _triggerRule:
		Trigger.MOVE_BACK_TWO:
			await player.movePlayerXSpaces(-2);
		Trigger.DISCARD_TICKET:
			player.removeEscapeTicket();
		Trigger.FORFEIT_DIE:
			TurnManager.spend_die();
			
func does_grant_special_die():
	return _effectRule == Effect.ROLL_SPECIAL_DIE;
	
func does_grant_reroll():
	return _effectRule == Effect.REROLL_DIE;
	
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
			Events.gain_die_roll.emit(false);
		GroupRules.Effect.ROLL_SPECIAL_DIE:
			Events.gain_die_roll.emit(true);
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
	
