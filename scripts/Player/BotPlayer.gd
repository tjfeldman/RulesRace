extends "res://scripts/Player/PlayerCharacter.gd"
class_name BotPlayer

"""
BASIC BOT PLAYER LOGIC
Action Prio:
	USE ESCAPE TICKET
	ROLL SPECIAL DIE
	ROLL DIE
	END TURN
"""
const BASIC_ACTION_PRIO = [Actions.Type.TICKET, Actions.Type.SPECIAL, Actions.Type.DIE, Actions.Type.END]
const OFFICE_CHOICES = [OfficeChoice.Option.TICKET, OfficeChoice.Option.DIE, OfficeChoice.Option.RULE]

func setActionOptions(options: Dictionary[Actions.Type, Callable]):
	print("In Bot Player");
	#Bot Player waits a bit for human players
	await get_tree().create_timer(0.5).timeout;
	for action in BASIC_ACTION_PRIO:
		if options.has(action):
			options[action].call();
			return null; #exit out of function

func selectOfficeReward():
	print("Selecting Office Reward as Bot Player");
	#Bot Player waits a bit for human players
	await get_tree().create_timer(0.5).timeout;
	return OFFICE_CHOICES.pick_random(); #Basic Bot picks a random choice
