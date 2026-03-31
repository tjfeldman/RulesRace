extends "res://scripts/Player/PlayerCharacter.gd"
class_name BotPlayer

"""
Action Prio:
	USE ESCAPE TICKET
	ROLL SPECIAL DIE
	USE GROUP RULE
	ROLL DIE
	END TURN
"""
const ACTION_PRIO = [Actions.Type.TICKET, Actions.Type.SPECIAL, Actions.Type.GROUP, Actions.Type.DIE, Actions.Type.END]
const OFFICE_CHOICES = [OfficeChoice.Option.TICKET, OfficeChoice.Option.DIE, OfficeChoice.Option.RULE]

var _bot_prio;
func _ready() -> void:
	#basic bot does not use group actions
	_bot_prio = ACTION_PRIO.filter(func(a): return a != Actions.Type.GROUP);

func setActionOptions(options: Dictionary[Actions.Type, Callable]):
	#Bot Player waits a bit for human players
	await get_tree().create_timer(0.5).timeout;
	for action in _bot_prio:
		if options.has(action):
			options[action].call();
			return null; #exit out of function

func selectOfficeReward():
	#Bot Player waits a bit for human players
	await get_tree().create_timer(0.5).timeout;
	return OFFICE_CHOICES.pick_random(); #Basic Bot picks a random choice

#Basic Bot only uses effects that are directly beneficial
func confirmGroupEffect():
	#Bot Player waits a bit for human players
	await get_tree().create_timer(0.5).timeout;
	return GroupRules.BENEFICIAL_EFFECTS.has(GroupRules.get_effect());

#Basic Bot only uses negative effects that target other players and selects randomly
func selectTargetPlayer(playerlist: Array[Player], is_can_rule):
	#Bot Player waits a bit for human players
	await get_tree().create_timer(0.5).timeout;
	if is_can_rule and GroupRules.HARMFUL_EFFECTS.has(GroupRules.get_effect()) or !is_can_rule:
		return playerlist.pick_random();
	return null;
