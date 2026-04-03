extends Node
class_name EventPair

"""
This class is meant to handle dealing with responses between turn actions
It stores the triggering player and the caused action
"""

enum ActionChecks {
	JAIL,
	ESCAPE,
	DISCARD,
	USE,
}

var _player: Player;
var _action: ActionChecks;

func _init(a: Player,b: ActionChecks):
	_player = a;
	_action = b;
	
func get_player() -> Player: return _player;
func get_action() -> ActionChecks: return _action;
