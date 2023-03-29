% Heuristic Improvement.
% Since I know the end is at the bottom towards the left,
% I just rearranged the move() function a little bit
% and make it prefer the following movements:
% Down -> Left -> Right -> Up.
% Theoratically it should improve the path finding by just a little bit.

% Codes from class.
wall([X,1]) :- X =\= 2.
wall([X,2]) :- X = 1; X = 4; X = 6.
wall([X,3]) :- X = 1; X = 2; X = 6.
wall([X,4]) :- X =\= 3,X =\= 5.
wall([X,5]) :- X = 1; X = 4; X = 6.
wall([X,6]) :- X =\= 2.
start([2,1]).
end([2,6]).
mazeSize([6,6]).

badSpot([X,Y]) :- wall([X,Y]).
badSpot([X,Y]) :- X < 1; Y < 1.
badSpot([X,Y]) :- mazeSize([W, H]), (X > W; Y > H).

solve(CurrentLocation, _, Path) :- end(CurrentLocation), Path = [CurrentLocation].
solve(CurrentLocation, BeenThere, Path) :- move(CurrentLocation, NewLocation),
        \+badSpot(NewLocation),
        \+member(NewLocation, BeenThere),
        solve(NewLocation, [NewLocation | BeenThere], RestOfPath),
        Path = [CurrentLocation | RestOfPath].

% Convenience rule
solve(Path) :- start(Start), solve(Start, [Start], Path).

drawCell(Column, Row, _) :- wall([Column, Row]), write("X"), !.
drawCell(Column, Row, _) :- start([Column, Row]), write("S"), !.
drawCell(Column, Row, _) :- end([Column, Row]), write("E"), !.
drawCell(Column, Row, Path) :- member([Column, Row], Path), write("P"), !.
drawCell(_, _, _) :- write("O").
drawRow(Row, Path) :- drawCell(1, Row, Path), tab(1), drawCell(2, Row, Path), tab(1),
        drawCell(3, Row, Path), tab(1), drawCell(4, Row, Path), tab(1),
        drawCell(5, Row, Path), tab(1), drawCell(6, Row, Path), nl.
draw :- drawRow(1, []), drawRow(2, []), drawRow(3, []), drawRow(4, []), drawRow(5, []),
        drawRow(6, []).
draw(Path) :- drawRow(1, Path), drawRow(2, Path), drawRow(3, Path), drawRow(4, Path),
        drawRow(5, Path), drawRow(6, Path).

% Modified code.
% Try to move down first.
move([CurrX, CurrY], [NextX, NextY]) :- NextY is CurrY + 1, NextX = CurrX.
% Then try to move left.
move([CurrX, CurrY], [NextX, NextY]) :- NextY = CurrY, NextX is CurrX - 1.
% Then try to move right.
move([CurrX, CurrY], [NextX, NextY]) :- NextY = CurrY, NextX is CurrX + 1.
% Hopefully this program never moves up.
move([CurrX, CurrY], [CurrX, NextY]) :- NextY is CurrY - 1.
