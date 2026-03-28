extends Node
class_name GroupAction

enum CostType {
	NONE,
	MOVE_BACK,
	TICKET,
	DIE
}

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

var _action_cost_type: CostType;
var _action_effect: GroupRules.Effect;
var _action_when: GroupRules.When;

func getActionCost(): return _action_cost_type;

func _init(
	actionWhen: GroupRules.When = GroupRules.When.NONE,
	trigger_rule: GroupRules.Trigger = GroupRules.Trigger.NONE, 
	effect: GroupRules.Effect = GroupRules.Effect.NONE
) -> void:
	match trigger_rule:
		GroupRules.Trigger.MOVE_BACK_TWO:
			_action_cost_type = CostType.MOVE_BACK;
		GroupRules.Trigger.DISCARD_TICKET:
			_action_cost_type = CostType.TICKET;
		GroupRules.Trigger.FORFEIT_DIE:
			_action_cost_type = CostType.DIE;
		_:
			_action_cost_type = CostType.NONE;
	_action_effect = effect;
	_action_when = actionWhen;
	
func isGrantSpecialDie():
	return _action_effect == GroupRules.Effect.ROLL_SPECIAL_DIE;
	
func isGrantReroll():
	return _action_effect == GroupRules.Effect.REROLL_DIE;

func isValid():
	return _action_cost_type != CostType.NONE;
	
func canPay(player: Player, hasNormalDie):
	var canActivate = GroupRules.verify_when(player, _action_when);
	if canActivate and GroupRules.verify_player_can_use_rule(player, _action_effect):
		match _action_cost_type:
			CostType.MOVE_BACK:
				return !player.isInJail() and player.getBoardPosition() >= 2;
			CostType.TICKET:
				return player.getEscapeTicketCount() >= (2 if _action_effect == GroupRules.Effect.TRANSFER_TICKET else 1);
			CostType.DIE:
				return hasNormalDie;
			_:
				return true;
	else:
		return false;
		
func getCostString():
	match _action_cost_type:
		CostType.MOVE_BACK:
			return "(-2 Spaces)";
		CostType.TICKET:
			return "(-1 Ticket)";
		CostType.DIE:
			return "(Forfeit Roll)";
		_:
			return null;
			
func getEffect():
	return _action_effect;
	
func getEffectLabel():
	return LABEL_TEXT[_action_effect];
