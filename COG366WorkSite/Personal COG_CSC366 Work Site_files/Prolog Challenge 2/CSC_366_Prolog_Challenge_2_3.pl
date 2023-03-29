% Do Your Own Thing!

% When I was checking my prevous programs with trace,
% I noticed that a majority of the effort the program spend on
% is checking if an location is a badspot, a wall, or out of bound.
% So I think that if I reduce the functions needed for badspot
% checking, the maze solving will be shortened dramatically.
% But that's just an theory though, because I can't notice
% the difference since computers does like billions of
% calculations per second.
%
% So for this program I'm cutting down on the world
% representations dramatically, every location is
% either path, start, or end.

% Allowed locations.
start([2, 1]).
end([2, 6]).
path([2, Y]) :- Y = 1; Y = 2; Y = 5; Y = 6.
path([3, Y]) :- Y = 2; Y = 3; Y = 4; Y = 5.
path([4, 3]).
path([5, Y]) :- Y = 2; Y = 3; Y = 4; Y = 5.

% Movements: Down -> Left -> Right -> Up.
move([X, Y], [NewX, NewY]) :- NewX = X, NewY is Y + 1.
move([X, Y], [NewX, NewY]) :- NewX is X - 1, NewY = Y.
move([X, Y], [NewX, NewY]) :- NewX is X + 1, NewY = Y.
move([X, Y], [NewX, NewY]) :- NewX = X, NewY is Y - 1.

% Main recursion.
solve(Location, _, Path) :- end(Location), Path = [Location].
solve(Location, Record, Path) :-
    move(Location, NextLocation),
    path(NextLocation),
    \+member(NextLocation, Record),
    solve(NextLocation, [NextLocation|Record], RestOfPath),
    Path = [Location|RestOfPath].


% Called function.
solve(Path) :- start(Start), solve(Start, [Start], Path).
