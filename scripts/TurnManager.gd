extends Node
class_name TurnManager 

var _group_rule_manager: Control;
var _personal_rule_manager: PersonalRuleManager;

var _turn_player: Player;
func get_turn_player() -> Player: return _turn_player;
var _round_order: Array[Player];

#TODO: Maybe player should hold their die
var _hasRoll: bool = false;
var _hasReroll: bool = false;
var _hasSpecialDie: bool = false;
func spend_die(): _hasRoll = false;

var _queue: Array[EventPair];

func _init(group_rule_manager: Control, personal_rule_manager: PersonalRuleManager) -> void:
	#Register Event Listeners
	Events.gain_die_roll.connect(_gain_die);
	Events.action_trigger.connect(_add_to_queue);
	
	#set variables
	_group_rule_manager = group_rule_manager;
	_personal_rule_manager = personal_rule_manager;
	
	pass;

func startRace():
	_round_order = PlayerManager.getPlayers();
	_start_next_turn();
	
"""
When a player's turn starts, they roll a die.
Before they roll this die, they can use an escape ticket or group rule.
Once they roll the standard die, their turn ends and they cannot use escape tickets or group rules.
"""	
func _start_next_turn():
	if PlayerManager.isGameOver(): return; #End the Game
	#refresh round order if round order is empty
	if _round_order.is_empty(): _round_order = PlayerManager.getPlayers();
	_turn_player = _round_order.pop_front();
	_hasRoll = true;
	_hasReroll = false;
	_hasSpecialDie = false;

	#update turn status
	Events.update_game_status.emit("%s's Turn" % _turn_player.playerName);
	await _calculate_actions();
	
func _calculate_actions():
	await _verify_all_players_ready();
	#if player has finished, instantly end their turn and move to nextr player
	if _turn_player.hasFinished():
		_start_next_turn();
		return;#make sure we break out of function
		
	#create a dictionary of actions.
	#Key = Actions
	#Value = callable func
	var actions: Dictionary[Actions.Type, Callable];
	#If When is Prison and turn player is in prison, then group rule can always be activated.
	if GroupRules.When.PRISON and _turn_player.isInJail() and _can_use_group_rule():
		actions[Actions.Type.GROUP] = _use_group_rule;
	if _hasRoll:
		#if the player has a normal die, it is the start of their turn
		actions[Actions.Type.DIE] = _roll_die;
		if _turn_player.isInJail() and _turn_player.hasEscapeTicket():
			actions[Actions.Type.TICKET] = _use_escape_ticket;
		if _can_use_group_rule():
			actions[Actions.Type.GROUP] = _use_group_rule;
	elif _hasSpecialDie:
		#if the player has special die then the only action they should have access to is rolling the special die
		actions[Actions.Type.SPECIAL] = _roll_special_die;
	elif _hasReroll:
		#if the player has a reroll, then they can only reroll the die
		actions[Actions.Type.DIE] = _roll_die;
	else:
		#if none of the above, then it is the player's end of turn
		actions[Actions.Type.END] = _start_next_turn;
	_turn_player.setActionOptions(actions);

func _gain_die(special_die: bool):
	if special_die:
		_hasSpecialDie = true;
	else:
		_hasReroll = true;

func _can_use_group_rule():
	var canPay = _group_rule_manager.can_pay(_turn_player, _hasRoll);
	
	#If the rule grants special dice, the player does not already have a special die
	if _group_rule_manager.does_grant_special_die():
		return canPay and not _hasSpecialDie;
	#if the rule grants a reroll, the player does not have their roll
	elif _group_rule_manager.does_grant_reroll():
		return canPay and not _hasRoll
	#otherwise just make sure the cost can be paid
	return canPay;

"""
Callable Functions for Actions
"""
func _roll_die():
	Events.update_game_status.emit("%s is rolling the die" %_turn_player.playerName);
	_hasRoll = false;
	_hasReroll = false;
	Events.roll_die.emit(false);
	
func _roll_special_die():
	Events.update_game_status.emit("%s is rolling the special die" %_turn_player.playerName);
	_hasSpecialDie= false;
	Events.roll_die.emit(true);
	
func _use_escape_ticket():
	Events.update_game_status.emit("%s used an escape ticket to leave jail" % _turn_player.playerName);
	_turn_player.removeEscapeTicket();
	await _turn_player.escapeFromJail();
	await _calculate_actions();

func _use_group_rule():
	#first we pay the cost
	await _group_rule_manager.pay_cost_for_player(_turn_player);
	#slight delay
	await get_tree().create_timer(0.5).timeout;
	#next we perform the action
	await _group_rule_manager.trigger_effect_for_player(_turn_player);
	await _calculate_actions();

"""
Handle Turn Actions
"""
func _on_dice_has_rolled(_type: Dice.Type, roll: Variant) -> void:
	roll = "Jail";
	await _personal_rule_manager.check_roll_condition(_turn_player, roll);
	if await _group_rule_manager.check_roll_trigger(_turn_player, roll):
		await _calculate_actions();
		return;#break out of function
	match roll:
		"Jail":
			var sentToJail = await _turn_player.sendToJail();
			if sentToJail:
				Events.update_game_status.emit("%s went to jail" %_turn_player.playerName);
			await _calculate_actions();
		"Escape":
			var escapeFromJail = await _turn_player.escapeFromJail();
			if escapeFromJail:
				Events.update_game_status.emit("%s escaped jail" %_turn_player.playerName);
			await _calculate_actions();
		_:
			if !_turn_player.isInJail(): 
				Events.update_game_status.emit("%s is moving %s spaces" %[_turn_player.playerName, roll]);
				await _turn_player.movePlayerXSpaces(roll);
				#if player moves onto office space via roll, then they can pick an office space reward
				if _turn_player.on_office_space():
					await _handle_office_space();
			await _calculate_actions();
				

func _handle_office_space():
	Events.update_game_status.emit("%s landed on office" %_turn_player.playerName);
	var picked = await _turn_player.selectOfficeReward();
	match picked:
		OfficeChoice.Option.TICKET:
			Events.update_game_status.emit("%s recieved an escape ticket" % _turn_player.playerName);
			_turn_player.addEscapeTicket();
		OfficeChoice.Option.DIE:
			Events.update_game_status.emit("%s can roll the special die" % _turn_player.playerName);
			_gain_die(true);
		OfficeChoice.Option.RULE:
			Events.update_game_status.emit("%s is changing the group rule" % _turn_player.playerName);
			_group_rule_manager.prompt_group_rule_change_for_player(_turn_player);
	
"""
Handle Between Turn Actions
"""
func _verify_all_players_ready():
	#Let's empty the event queue
	while !_queue.is_empty():
		#slight delay between checks
		await get_tree().create_timer(0.3).timeout;
		var pair: EventPair = _queue.pop_front();
		await _personal_rule_manager.check_event_condition(pair);
		await _group_rule_manager.trigger_event(pair);
	
	#We we check if there are out of turn group actions
	#TODO: Instead of prompting individually each time, create a new prompt that asks the player how many escape tickets to discard
	if GroupRules.get_when() == GroupRules.When.PRISON and GroupRules.get_trigger() == GroupRules.Trigger.DISCARD_TICKET:
		var repeat = false;
		var prisoners = PlayerManager.getPrisonPlayers();
		if prisoners.is_empty(): return; #break if no prisoners
		for prisoner in prisoners:
			#no need to spam the turn player when they can use the group rule themselves
			#TODO: Update Game Status so other players know someone is considering using a group rule
			if prisoner != _turn_player and await prisoner.confirmGroupEffect():
				repeat = true;
				await _group_rule_manager.pay_cost_for_player(prisoner)
				await _group_rule_manager.trigger_effect_for_player(prisoner);
		#END FOR
		if repeat: await _verify_all_players_ready();

func _add_to_queue(pair: EventPair):
	_queue.push_back(pair);
