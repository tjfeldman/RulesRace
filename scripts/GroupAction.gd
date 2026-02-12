extends Node
class_name GroupAction

enum CostType {
	NONE,
	MOVE_BACK,
	TICKET,
}

var _action_cost_type: CostType;
var _action_effect: GroupRules.Effect;

func _init(trigger_rule: GroupRules.Trigger = GroupRules.Trigger.NONE, effect: GroupRules.Effect = GroupRules.Effect.NONE):
	match trigger_rule:
		GroupRules.Trigger.MOVE_BACK_TWO:
			_action_cost_type = CostType.MOVE_BACK;
		GroupRules.Trigger.DISCARD_TICKET:
			_action_cost_type = CostType.TICKET;
		_:
			_action_cost_type = CostType.NONE;
	_action_effect = effect;

func isValid():
	return _action_cost_type != CostType.NONE;
	
func canPay(player: Player):
	var canBenefit = GroupRules.verify_player_can_use_rule(player, _action_effect);
	if canBenefit:
		match _action_cost_type:
			CostType.MOVE_BACK:
				return !player.isInJail() and player.getBoardPosition() >= 2;
			CostType.TICKET:
				return player.getEscapeTicketCount() >= (2 if _action_effect == GroupRules.Effect.TRANSFER_TICKET else 1);
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
		_:
			return "(Cost)"

func performAction(player: Player):
	#pay the cost, then perform effect
	match _action_cost_type:
		CostType.MOVE_BACK:
			player.movePlayerXSpaces(-2);
		CostType.TICKET:
			player.removeEscapeTicket();
	Events.emit_signal("perform_rule_effect", player);
