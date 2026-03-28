extends "res://scripts/Player/BotPlayer.gd"
class_name SmartBotPlayer

func setActionOptions(options: Dictionary[Actions.Type, Callable]):
	#Bot Player waits a bit for human players
	await get_tree().create_timer(0.5).timeout;
	for action in ACTION_PRIO:
		if options.has(action):
			var use_action = true;
			if action == Actions.Type.GROUP:
				use_action = _should_use_group_rule();
			if use_action: 
				options[action].call();
				return null; #exit out of function

func _should_use_group_rule():
	"""
	Smart Bot will use group rules that do not hinder it's progress
	"""	
	var action_cost = GroupRules.group_action.getActionCost();
	var will_pay_cost = action_cost in [GroupRules.group_action.CostType.TICKET, GroupRules.group_action.CostType.DIE];
	if !will_pay_cost: return false; #exit early if we won't pay the cost
	
	var action_effect = GroupRules.group_action.getEffect();
	var wants_effect = false;
	match action_effect:
		GroupRules.Effect.MOVE_ONE:
			#Moving 1 is only valuable if it costs a ticket and we have more than 1.
			wants_effect = action_cost == GroupRules.group_action.CostType.TICKET and self._escapeTickets > 1;
		GroupRules.Effect.GAIN_TICKET:
			#Only valuable if we have no escape tickets and the cost is forfeiting die
			wants_effect = action_cost == GroupRules.group_action.CostType.DIE and self._escapeTickets == 0;
		GroupRules.Effect.MOVE_TO_PLAYER_AHEAD:
			#we will willing move to a player ahead if there is one, regardless of the cost
			wants_effect = PlayerManager.getPlayerAhead(self) != null;
		GroupRules.Effect.ROLL_SPECIAL_DIE:
			#no situation in which rolling the special die is not good
			wants_effect = true;
		GroupRules.Effect.SEND_PLAYER_BACK_ONE:
			#make sure that the leading player is not yourself
			wants_effect = PlayerManager.getLeadingPlayer() != self;
			if wants_effect:
				#We will spend escape tickets except 1 to send leading player back
				wants_effect = GroupRules.group_action.CostType.TICKET and self._escapeTickets > 1;
				
	return wants_effect;
	
func selectOfficeReward():
	#Bot Player waits a bit for human players
	await get_tree().create_timer(0.5).timeout;
	"""
	Smart Bot will create a group rule if non exist.
	Smart Bot will take an escape ticket if it has none.
	Smart Bot will roll the special die
	"""
	if !GroupRules.existing_group_rule():
		return OfficeChoice.Option.RULE;
	elif self._escapeTickets == 0:
		return OfficeChoice.Option.TICKET;
	else:
		return OfficeChoice.Option.DIE;
#
##Basic Bot only uses effects that are directly beneficial
#func confirmGroupEffect():
	##Bot Player waits a bit for human players
	#await get_tree().create_timer(0.5).timeout;
	#return GroupRules.BENEFICIAL_EFFECTS.has(GroupRules.group_action.getEffect());
#
#Basic Bot priotizes targeting the leading player with negative effects
func selectTargetPlayer(playerlist: Array[Player], is_can_rule):
	#Bot Player waits a bit for human players
	await get_tree().create_timer(0.5).timeout;
	if is_can_rule and GroupRules.HARMFUL_EFFECTS.has(GroupRules.group_action.getEffect()):
		var leading_player = PlayerManager.getLeadingPlayer();
		if leading_player in playerlist:
			return leading_player;
		return playerlist.pick_random();
	if !is_can_rule:
		return playerlist.pick_random(); 
	return null;
