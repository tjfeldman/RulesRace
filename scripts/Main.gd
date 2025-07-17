extends Node2D

@onready var player : Node2D = $PlayerToken;
@onready var board : Node2D = $Board;

func _on_dice_dice_has_rolled(roll: String) -> void:
	match roll:
		"Jail":
			player.sendToJail(board.jailTile.global_position);
		"Escape":
			player.escapeFromJail(board.getTile(player.getBoardPosition()).global_position);
		_:
			if !player.isInJail():
				print("Moving player %s space(s)" % roll);
				var moves = board.calculateMove(player.getBoardPosition(), int(roll));
				player.movePlayer(int(roll), moves);
			else:
				print("Cannot move player due to being in Jail");
