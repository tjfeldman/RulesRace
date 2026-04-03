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
static var _whenRule: When = When.NONE;
static var _triggerRule: Trigger = Trigger.NONE;
static var _effectRule: Effect = Effect.NONE;
#public getters
static func get_when(): return _whenRule;
static func get_trigger(): return _triggerRule;
static func get_effect(): return _effectRule;

var _canRules = [Trigger.ROLL_PRISON, Trigger.ROLL_ONE, Trigger.ROLL_TWO, \
				Trigger.ROLL_THREE, Trigger.MOVES_PRISON];
var _targetsAnotherPlayer = [Effect.TRANSFER_TICKET, Effect.SEND_PLAYER_BACK_ONE];

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
#checks if the player can activate the rule
func _verify_when(player: Player) -> bool:
	match _whenRule:
		When.TURN:
			return get_tree().current_scene.get_turn_player() == player;
		When.PRISON:
			return player.isInJail();
		When.LEADING:
			return PlayerManager.getLeadingPlayer() == player;
		_:
			return false;
	
func _verify_effect(player: Player) -> bool:
	#if player has made it to the goal, they cannot benefit from the effect
	if player.hasFinished(): return false;
	
	match _effectRule:
		Effect.MOVE_ONE:
			return !player.isInJail();
		Effect.MOVE_TO_PLAYER_AHEAD:
			return !player.isInJail() and PlayerManager.getPlayerAhead(player);
		Effect.MOVE_BACK:
			return !player.isInJail() and player.getBoardPosition() > 0;
		Effect.SEND_PLAYER_BACK_ONE:
			#we can't move players who are at the start, are currently in jail, or has finished the race
			return PlayerManager.getListOfAllOtherPlayers(player).filter(func(p): return p.getBoardPosition() > 0 and not p.isInJail() and not p.hasFinished());
		Effect.TRANSFER_TICKET:
			return player.hasEscapeTicket();
		Effect.REROLL_DIE, Effect.ROLL_SPECIAL_DIE:
			#dice can only be used on player's turn
			return get_tree().current_scene.get_turn_player() == player;
		_:
			return true;
	
"""
PUBLIC ACCESSIBLE FUNCTIONS
"""
func trigger_event(pair: EventPair) -> void:
	#The only relevant group event is another playing heading to jail
	if pair.get_action() == EventPair.ActionChecks.JAIL and _triggerRule == Trigger.MOVES_PRISON:
		var triggering_player = pair.get_player();
		var players = PlayerManager.getPlayers();
		for player in players:
			#verify the player can use the effect at this time as long as it is not the same player
			if _verify_effect(player) and _verify_when(player) and triggering_player != player:
				await trigger_effect_for_player(player);
				

func prompt_group_rule_change_for_player(player: Player) -> void:
	if player.isBot():
		group_rule_selector.random_rule();
	else:
		group_rule_selector.set_for_editing();
		
func trigger_effect_for_player(player: Player) -> void:
	var effect_info;
	if _effectRule in _targetsAnotherPlayer:
		effect_info = await _target_effect(player);
	else:
		effect_info = await _trigger_effect(player);
		
	if effect_info:
		_update_game_status(player, effect_info[1]);
		await effect_info[0].call();
		
func check_roll_trigger(turn_player: Player, roll: Variant) -> bool:
	#if the when condition is not met or player is in jail
	#then we return false
	if not _verify_when(turn_player) or turn_player.isInJail():
		return false;
		
	match [_triggerRule, roll]:
		[Trigger.ROLL_PRISON, "Jail"]:
			#DO NOT GO TO JAIL AND CAN USE EFFECT
			if _verify_effect(turn_player):
				await trigger_effect_for_player(turn_player);
			return true;
		[Trigger.ROLL_ONE, 1]:
			#MOVE PLAYER FORWARD 1 AND CAN USE EFFECT
			await turn_player.movePlayerXSpaces(1);
			if _verify_effect(turn_player):
				await trigger_effect_for_player(turn_player);
			return true;
		[Trigger.ROLL_TWO, 2]:
			#MOVE PLAYER FORWARD 2 AND CAN USE EFFECT
			await turn_player.movePlayerXSpaces(2);
			if _verify_effect(turn_player):
				await trigger_effect_for_player(turn_player);
			return true;
		[Trigger.ROLL_THREE, 3]:
			#MOVE PLAYER FORWARD 3 AND CAN USE EFFECT
			await turn_player.movePlayerXSpaces(3);
			if _verify_effect(turn_player): 
				await trigger_effect_for_player(turn_player);
			return true;
		_:
			return false;
	#END MATCH

func can_pay(player: Player, hasNormalDie) -> bool:
	var canActivate = _verify_when(player);
	if canActivate and _verify_effect(player):
		match _triggerRule:
			Trigger.MOVE_BACK_TWO:
				return !player.isInJail() and player.getBoardPosition() >= 2;
			Trigger.DISCARD_TICKET:
				return player.getEscapeTicketCount() >= (2 if _effectRule == Effect.TRANSFER_TICKET else 1);
			Trigger.FORFEIT_DIE:
				return hasNormalDie;
		#END MATCH
	return false; #If cannot activate or not a proper trigger, return false
	
func pay_cost_for_player(player: Player) -> void:
	match _triggerRule:
		Trigger.MOVE_BACK_TWO:
			await player.movePlayerXSpaces(-2);
		Trigger.DISCARD_TICKET:
			player.removeEscapeTicket(true);
		Trigger.FORFEIT_DIE:
			get_tree().current_scene.spend_die();
			
func does_grant_special_die() -> bool:
	return _effectRule == Effect.ROLL_SPECIAL_DIE;
	
func does_grant_reroll() -> bool:
	return _effectRule == Effect.REROLL_DIE;
	
"""
PRIVATE FUNCTIONS
"""
func _on_background_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_click") and not group_rule_selector.isEditing():
		group_rule_selector.visible = !group_rule_selector.visible;
		get_tree().current_scene.toggle_hud(!group_rule_selector.visible);
		
func _on_rules_updated(_whenRuleBtn: RuleButton, _triggerRuleBtn: RuleButton, _effectRuleBtn: RuleButton):
	whenLabel.text = _whenRuleBtn.description;
	triggerLabel.text = _triggerRuleBtn.description;
	effectLabel.text = _effectRuleBtn.description;
	
	_whenRule = _whenRuleBtn.type;
	_triggerRule = _triggerRuleBtn.type;
	_effectRule = _effectRuleBtn.type;
	
	get_tree().current_scene.toggle_hud(true);

func _trigger_effect(affectedPlayer: Player):
	#if the rule can be used, asked the player if they want to use it
	if _triggerRule in _canRules:
		#exit if they decline
		if await affectedPlayer.confirmGroupEffect() == false: return null;
	match _effectRule:
		Effect.MOVE_ONE:
			return [affectedPlayer.movePlayerXSpaces.bind(1), "move forward 1 space"];
		Effect.GAIN_TICKET:
			return [affectedPlayer.addEscapeTicket, "gain 1 escape ticket"];
		Effect.REROLL_DIE:
			return [Events.gain_die_roll.emit.bind(false), "roll their die again"];
		Effect.ROLL_SPECIAL_DIE:
			return [Events.gain_die_roll.emit.bind(true), "gain a special die to roll"];
		Effect.MOVE_TO_PLAYER_AHEAD:
			var ahead_player = PlayerManager.getPlayerAhead(affectedPlayer);
			return [affectedPlayer.moveToPlayer.bind(ahead_player), "move to the space of %s"%ahead_player.playerName];
		Effect.MOVE_BACK:
			return [affectedPlayer.movePlayerXSpaces.bind(-1), "move back 1 space"];
	#END MATCH
#END FUNC
				
func _target_effect(affectedPlayer: Player):
	#we can't move players who are at the start or are currently in jail
	var playerlist = PlayerManager.getListOfAllOtherPlayers(affectedPlayer);
	var is_can_rule = _triggerRule in _canRules;
	match _effectRule:
		Effect.SEND_PLAYER_BACK_ONE:
			#can't move players who are at start or currently in jail
			playerlist.filter(func(p): return p.getBoardPosition() > 0 and not p.isInJail());
			var target = await affectedPlayer.selectTargetPlayer(playerlist, is_can_rule);
			if target:	#if no target is selected, exit
				return [target.movePlayerXSpaces.bind(-1), "send %s back 1 space"%affectedPlayer.playerName];
		Effect.TRANSFER_TICKET:
			var target = await affectedPlayer.selectTargetPlayer(playerlist, is_can_rule);
			if target:	#if no target is selected, exit
				return [affectedPlayer.transferEscapeTicket.bind(target), "transfer 1 escape ticket to %s"%target.playerName];
	#END MATCH
#END FUNC
	
func _update_game_status(user: Player, effect_info: String) -> void:
	if effect_info.is_empty(): return; #break if no info to update
	var trigger_info = "";
	match _triggerRule:
		Trigger.ROLL_PRISON:
			trigger_info = "rolls prison and";
		Trigger.ROLL_ONE:
			trigger_info = "rolls 1 and";
		Trigger.ROLL_TWO:
			trigger_info = "rolls 2 and";
		Trigger.ROLL_THREE:
			trigger_info = "rolls 3 and";
		#TODO: Implement
		Trigger.MOVES_PRISON:
			trigger_info = "because another player went to prison chose to"
		Trigger.MOVE_BACK_TWO:
			trigger_info = "moves back 2 spaces to";
		Trigger.DISCARD_TICKET:
			trigger_info = "discards a ticket to";
		Trigger.FORFEIT_DIE:
			trigger_info = "gives up their roll to";
	#END MATCH
	Events.update_game_status.emit("%s %s %s"%[user.playerName, trigger_info, effect_info]);
		
