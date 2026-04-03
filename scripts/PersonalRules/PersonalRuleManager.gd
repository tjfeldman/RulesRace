extends Node
class_name PersonalRuleManager

"""
STATIC
"""
#Register the Personal Rule condition with an Array of players
static var _registered_conditions: Dictionary[PersonalRules.Condition, Array];

static func register_personal_rule(player: Player):
	var rule = player.getPersonalRule();
	
	#register condition to dictionary
	var condition_arr = _registered_conditions.get_or_add(rule.get_condition(), []);
	condition_arr.append(player);
	
"""
Class
"""
#This function checks to see if any players' personal rule will trigger on a roll and returns an array of actions
func check_roll_condition(roller: Player, roll: Variant) -> void:
	var condition = null;
	match roll:
		1:
			condition = PersonalRules.Condition.ROLL_ONE;
		2:
			condition = PersonalRules.Condition.ROLL_TWO;
		3:
			condition = PersonalRules.Condition.ROLL_THREE;
		"Jail":
			condition = PersonalRules.Condition.ROLL_PRISON;
		"Escape":
			condition = PersonalRules.Condition.ROLL_ESCAPE;
	#END MATCH
	
	#If the player_arr exists, then for each player in the arr we should check their trigger
	await _check_personal_rule_condition(roller, condition);
			
func check_event_condition(pair: EventPair) -> void:
	var condition = null;
	match pair.get_action():
		EventPair.ActionChecks.JAIL:
			condition = PersonalRules.Condition.SENT_JAIL;
		EventPair.ActionChecks.ESCAPE:
			condition = PersonalRules.Condition.ESCAPE_JAIL;
		EventPair.ActionChecks.DISCARD:
			condition = PersonalRules.Condition.DISCARD_TICKET;
			
	#END MATCH
	await _check_personal_rule_condition(pair.get_player(), condition);

"""
Private Functions
"""
func _check_personal_rule_condition(causer: Player, condition: PersonalRules.Condition):
	#If the player_arr exists, then for each player in the arr we should check their trigger
	var player_arr = _registered_conditions.get(condition);
	if player_arr: for player in player_arr:
		if player.hasFinished(): player_arr.erase(player); #remove player from registery if they have finished
		else: await _check_personal_rule_trigger(player, causer, condition);
	
				
func _check_personal_rule_trigger(player: Player, causer: Player, condition: PersonalRules.Condition):
	var valid: bool = false;
	match player.getPersonalRule().get_trigger():
		PersonalRules.Trigger.SAME_SPACE:
			#Trigger is valid is player is not the causer and is sharing a space with the causer
			valid = player != causer and player.is_sharing_space_with_player(causer, condition);
		PersonalRules.Trigger.PRISON:
			#Trigger is valid is the condition is ESCAPING JAIL or the causer is in jail
			valid = condition == PersonalRules.Condition.ESCAPE_JAIL || causer.isInJail();
				
	#END MATCH
	if valid: 
		var info = _find_rule_target(player);
		if info: 
			Events.update_game_status.emit("%s activated their personal rule: %s"%[player.playerName, info[1]]);
			await info[0].call();
				
#Locate the target of the personal rule
func _find_rule_target(player: Player):
	var rule = player.getPersonalRule()
	match rule.get_target():
		PersonalRules.Target.I:
			var arr = _trigger_effect(rule.get_effect(), player);
			if arr: return [arr[0], "%s %s"%[player.playerName, arr[1]]];
				
func _trigger_effect(effect: PersonalRules.Effect, target: Player): 
	match effect:
		PersonalRules.Effect.MOVE_ONE:
			if !target.isInJail(): #players in jail cannot move
				#await target.movePlayerXSpaces(1);
				return [target.movePlayerXSpaces.bind(1), "moves one space"];
