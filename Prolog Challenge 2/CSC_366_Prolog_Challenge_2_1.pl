% Follow the Left Wall.

% Codes from class.
wall([X,1]) :- X =\= 2.
wall([X,2]) :- X = 1; X = 4; X = 6.
wall([X,3]) :- X = 1; X = 2; X = 6.
wall([X,4]) :- X =\= 3,X =\= 5.
wall([X,5]) :- X = 1; X = 4; X = 6.
wall([X,6]) :- X =\= 2.
mazeSize([6,6]).

% Modified slightly.
drawCell(Column, Row, _) :- wall([Column, Row]), write("X"), !.
drawCell(Column, Row, _) :- start([Column, Row, _]), write("S"), !.
drawCell(Column, Row, _) :- end([Column, Row, _]), write("E"), !.
drawCell(Column, Row, Path) :- member([Column, Row, _], Path), write("P"), !.
drawCell(_, _, _) :- write("O").

drawRow(Row, Path) :- drawCell(1, Row, Path), tab(1), drawCell(2, Row, Path), tab(1),
        drawCell(3, Row, Path), tab(1), drawCell(4, Row, Path), tab(1),
        drawCell(5, Row, Path), tab(1), drawCell(6, Row, Path), nl.

draw :- drawRow(1, []), drawRow(2, []), drawRow(3, []), drawRow(4, []), drawRow(5, []),
        drawRow(6, []).
draw(Path) :- drawRow(1, Path), drawRow(2, Path), drawRow(3, Path), drawRow(4, Path),
        drawRow(5, Path), drawRow(6, Path).



% Modified code.
start([2, 1, down]).
end([2, 6, down]).
badSpot([X, Y, _]) :- wall([X,Y]).
badSpot([X, Y, _]) :- X < 1; Y < 1.
badSpot([X, Y, _]) :- mazeSize([W, H]), (X > W; Y > H).

% Wall on perspective left.
wallOnLeft([X, Y, up])   :- WX is X - 1, wall([WX, Y]).
wallOnLeft([X, Y, down]) :- WX is X + 1, wall([WX, Y]).
wallOnLeft([X, Y, left]) :- WY is Y + 1, wall([X, WY]).
wallOnLeft([X, Y, right]):- WY is Y - 1, wall([X, WY]).
% Wall on perspective front.
wallInFront([X, Y, up])   :- WY is Y - 1, wall([X, WY]).
wallInFront([X, Y, down]) :- WY is Y + 1, wall([X, WY]).
wallInFront([X, Y, left]) :- WX is X - 1, wall([WX, Y]).
wallInFront([X, Y, right]):- WX is X + 1, wall([WX, Y]).
% Wall on perspective right.
wallOnRight([X, Y, up])   :- WX is X + 1, wall([WX, Y]).
wallOnRight([X, Y, down]) :- WX is X - 1, wall([WX, Y]).
wallOnRight([X, Y, left]) :- WY is Y - 1, wall([X, WY]).
wallOnRight([X, Y, right]):- WY is Y + 1, wall([X, WY]).

% Go foward perspectively.
goForward([X, Y, up], [NewX, NewY, up]) :-
    NewX = X,
    NewY is Y - 1.
goForward([X, Y, down], [NewX, NewY, down]) :-
    NewX = X,
    NewY is Y + 1.
goForward([X, Y, left], [NewX, NewY, left]) :-
    NewX is X - 1,
    NewY is Y.
goForward([X, Y, right], [NewX, NewY, right]) :-
    NewX is X + 1,
    NewY is Y.

% Turn to perspective left and move 1 step.
turnLeft([X, Y, up], [NewX, NewY, left]) :-
    NewX is X - 1,
    NewY = Y.
turnLeft([X, Y, down], [NewX, NewY, right]) :-
    NewX is X + 1,
    NewY = Y.
turnLeft([X, Y, left], [NewX, NewY, down]) :-
    NewX = X,
    NewY is Y + 1.
turnLeft([X, Y, right], [NewX, NewY, up]) :-
    NewX = X,
    NewY is Y - 1.

% Turn to perspective right and move 1 step.
turnRight([X, Y, up], [NewX, NewY, right]) :-
    NewX is X + 1,
    NewY = Y.
turnRight([X, Y, down], [NewX, NewY, left]) :-
    NewX is X - 1,
    NewY = Y.
turnRight([X, Y, left], [NewX, NewY, up]) :-
    NewX = X,
    NewY is Y - 1.
turnRight([X, Y, right], [NewX, NewY, down]) :-
    NewX = X,
    NewY is Y + 1.

% Turn around perspectively and move 1 step.
turnAround([X, Y, up], [NewX, NewY, down]) :-
    NewX = X,
    NewY is Y + 1.
turnAround([X, Y, down], [NewX, NewY, up]) :-
    NewX = X,
    NewY is Y - 1.
turnAround([X, Y, left], [NewX, NewY, right]) :-
    NewX is X + 1,
    NewY = Y.
turnAround([X, Y, right], [NewX, NewY, left]) :-
    NewX is X - 1,
    NewY = Y.

% Movements.
% Keep Going.
move(ThisLocation, NewLocation) :-
    wallOnLeft(ThisLocation),
    goForward(ThisLocation, NewLocation).
% Turn Left.
move(ThisLocation, NewLocation) :-
    \+wallOnLeft(ThisLocation),
    turnLeft(ThisLocation, NewLocation).
% Turn Right.
move(ThisLocation, NewLocation) :-
    wallOnLeft(ThisLocation),
    wallInFront(ThisLocation),
    turnRight(ThisLocation, NewLocation).
% Turn Around.
move(ThisLocation, NewLocation) :-
    wallOnLeft(ThisLocation),
    wallInFront(ThisLocation),
    wallOnRight(ThisLocation),
    turnAround(ThisLocation, NewLocation).

% Main recursion.
solve(ThisLocation, _, Path) :- end(ThisLocation), Path=[ThisLocation].
solve(ThisLocation, Record, Path) :-
    move(ThisLocation, NextLocation),
    \+badSpot(NextLocation),
    \+member(NextLocation, Record),
    solve(NextLocation, [NextLocation|Record], RestOfPaths),
    Path = [ThisLocation|RestOfPaths].

% Called function.
solve(Path) :- start(Start), solve(Start, [Start], Path).


