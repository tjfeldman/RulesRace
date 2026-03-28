extends Node
class_name EventPair

"""
This class is meant to handle dealing with responses between turn actions
It stores the triggering player and the caused action
"""

enum ActionChecks {
	JAIL,
}

var player: Player;
var action: ActionChecks;

func _init(a: Player,b: ActionChecks):
	player = a;
	action = b;
	
