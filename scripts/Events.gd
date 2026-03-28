extends Node

#since this is an event bus class, the signals will never be used within the class itself
@warning_ignore_start("unused_signal")

#Player Events
signal updated_escape_tickets(player: Player);

#Action Events
signal gain_die_roll(special: bool);

#Move Events
signal player_moved();
signal player_reached_goal(player: Player);

#Group Rule Events
signal action_trigger(pair: EventPair);

#Game Over Event
signal game_over();
