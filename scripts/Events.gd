extends Node

#since this is an event bus class, the signals will never be used within the class itself
@warning_ignore_start("unused_signal")

#Main Events
signal update_game_status(info: String);

#Player Events
signal updated_escape_tickets(player: Player);

#Dice Events
signal roll_die(special: bool);
signal gain_die_roll(special: bool);

#Move Events
signal player_moved();
signal player_reached_goal(player: Player);

#Group Rule Events
signal action_trigger(pair: EventPair);

#Game Over Event
signal game_over();
