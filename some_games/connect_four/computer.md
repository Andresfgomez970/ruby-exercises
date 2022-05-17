For the creation of an algorithm to play agains the user I have the idea of a minmax algorithm that has a score in the form + 1 / n_play, - 1 / n_play, or 0.

The idea is something as follows:

score(
    table_before
    column
    n_play
    player
    )   

if player loose with this move (table_before, column, player)
    return - 1 / n_play
elsif player win with this move (table_before, column, player)
    return 1 / n_play 
else
    return 0

With this score fucntion create an algorithm to explore solutions to a given depth.

minmax needs to be able to go over the childs:
    in a firs proposal child can be composed of
        table_before
        column
        n_play
        player

for an overview of the minmax I am using: https://www.youtube.com/watch?v=l-hh51ncgDI