v0.3 Tasklist
- [ ] Group Rule can be changed when landing on the office space.
- [ ] Create a BotPlayer class that inherits the Player class.
- [ ] BotPlayer class now handles logic for determing the bot's next move
- [ ] ActionManager needs to verify all players are ready for the TurnState to change
- [ ] BotPlayer should have two modes. First mode just rolls dice and picks randomly when prompted. Second mode should extend the first mode, but attempt to utilize Group Rules.
- [ ] Have 2 BotPlayers added to the board. 1 being the basic bot. 1 being the rule using bot.
- [ ] Game should now end when all but 1 player has reach the end. This should call a function that currently closes the game.

V0.2 Tasklist (Every Check is ~0.004)
- [x] Add UI element with buttons for actions
- [x] Revamp State Manager with UI.
- [x] Add Group Rule UI element that shows current group rule selection and also shows other rules. Group rule categories: When, Trigger, Effect
- [x] Add Group Rule Manager
- [x] Add Group Rule check for When category of "Every player, on their turn"
- [x] Add Group Rule check for When category of "At any time, player(s) in prison"
- [x] Add Group Rule check for When category of "The leading player(s), on their turn,"
- [x] Add Group Rule check for Trigger category of "If they roll Prison, they won't move to Prison, and can"
- [x] Add Group Rule check for Trigger category of "If they roll 1, they will move one space and then can"
- [x] Add Group Rule check for Trigger category of "If they roll 2, they will move two space and then can"
- [x] Add Group Rule check for Trigger category of "If they roll 3, they will move three space and then can"
- [x] Add Group Rule check for Trigger category of "every time another player goes to Prison, they can"
- [x] Add Group Rule check for Trigger category of "they can move 2 spaces backwards and then"
- [x] Add Group Rule check for Trigger category of "they can discard an escape ticket(s) and"
- [x] Add Group Rule check for Trigger category of "they can forfeit their dice roll and"
- [x] Add Group Rule action for Effect category of "move one space forward"
- [x] Add Group Rule action for Effect category of "gain one escape ticket"
- [x] Add Group Rule action for Effect category of "give one escape ticket to a different player"
- [x] Add Group Rule action for Effect category of "roll the dice again"
- [x] Add Group Rule action for Effect category of "move to the space of the player in front of them"
- [x] Add Group Rule action for Effect category of "move one space backward"
- [x] Add Group Rule action for Effect category of "roll the special die"
- [x] Add Group Rule action for Effect category of "send one other player one space backward"

V0.1 Tasklist
- [x] Add Board, Player Token, and Die. Player Token moves based on the Die's roll. Includes Jail space.
- [x] Add Tile Object that contains information about Tile Color and if Tile is a special tile. 
- [x] When player's land on a special tile, a pop up appears giving them options.
- [x] Add Inventory to Player to store Escape Tickets. 
- [x] Allow Escape Tickets to be used to get out of Jail.
- [x] Add UI Hub that shows the player and their inventory tickets.
- [x] Add Die animation when the player rolls. Add UI for player's roll.
- [x] Add special die that can be rolled when conditions are met.
- [x] Add State Manager that controls the turn.
- [x] Add a Bot Player that rolls die and moves.
