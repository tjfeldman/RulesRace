extends Node2D

@onready var player : Node2D = $PlayerToken;
@onready var board : Node2D = $Board;

func _on_dice_dice_has_rolled(roll: Variant) -> void:
	match roll:
		"Jail":
			player.sendToJail(board.getJailPosition());
		"Escape":
			player.escapeFromJail(board.getPlayerPosition(player));
		_:
			if !player.isInJail():
				var currentPosition = player.getBoardPosition();
				while roll > 0:
					currentPosition += 1;
					var nextTilePosition = board.getTilePosition(currentPosition);
					if nextTilePosition != null:
						await player.movePlayer(nextTilePosition);
					roll -= 1;
						
				#update board position after while loop
				player.setBoardPosition(currentPosition);
				
				#check if the tile landed on is an office space
				if board.isOfficeSpace(currentPosition):
					#TODO add popup
					print("Office Space Landed On");
