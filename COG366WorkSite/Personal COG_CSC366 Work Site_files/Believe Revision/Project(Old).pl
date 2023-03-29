% Stations
% Station(ThisStation, Connections) :-
%         Connections = [NextStation, Train, Weight].
station(1, Connections) :-
    Connections = [2, b, 1]; Connections = [14, b, 1].
station(2, Connections) :-
    Connections = [1, b, 1]; Connections = [3, b, 1].
station(3, Connections) :-
    Connections = [2, b, 1]; Connections = [4, b, 1].
station(4, Connections) :-
    Connections = [3, b, 1]; Connections = [11, b, 1];
    Connections = [11, a, 1]; Connections = [5, a, 1].
station(5, Connections) :-
    Connections = [4, a, 1]; Connections = [6, a, 1].
station(6, Connections) :-
    Connections = [5, a, 1]; Connections = [7, a, 1].
station(7, Connections) :-
    Connections = [6, a, 1]; Connections = [8, a, 1];
    Connections = [9, c, 1]; Connections = [15, c, 1].
station(8, Connections) :-
    Connections = [7, a, 1].
station(9, Connections) :-
    Connections = [7, c, 1]; Connections = [10, c, 1].
station(10, Connections) :-
    Connections = [11, c, 1]; Connections = [9, c, 1].
station(11, Connections) :-
    Connections = [10, c, 1]; Connections = [12, c, 1];
    Connections = [12, b, 1]; Connections = [4, b, 1];
    Connections = [4, a, 1].
station(12, Connections) :-
    Connections = [11, c, 1]; Connections = [13, c, 1];
    Connections = [11, b, 1]; Connections = [13, b, 1].
station(13, Connections) :-
    Connections = [12, c, 1]; Connections = [14, c, 1];
    Connections = [16, b, 1]; Connections = [12, b, 1].
station(14, Connections) :-
    Connections = [1, b, 1]; Connections = [16, b, 1];
    Connections = [13, c, 1]; Connections = [15, c, 1].
station(15, Connections) :-
    Connections = [7, c, 1]; Connections = [14, c, 1].
station(16, Connections) :-
    Connections = [14, b, 1]; Connections = [13, b, 1].


% Trains
train(Trains) :-
    Trains = a; Trains = b; Trains = c.

generateTrainStates([], []).
generateTrainStates([This|Rest], States) :-
    generateTrainStates(Rest, RestStates),
    States = [train(This, normal)|RestStates].

getTrainStates(TrainStates) :-
    findall(Trains, train(Trains), Result),
    generateTrainStates(Result, TrainStates).


% updateTrainStates([OriginalStates], Change, [NewStates]).
updateTrainStates([], _, []).
updateTrainStates([This|Rest], Change, NewStates) :-
    updateTrainStates(Rest, Change, OldStates),
    This = train(Train1, _),
    Change = train(Train2, _),
    (   Train1 = Train2
    ->  NewStates = [Change|OldStates]
    ;   NewStates = [This|OldStates]).


% Modifiers
% modifier(State, Modifier).
modifier(clean, 0.5).
modifier(normal, 1).
modifier(dirty, 1.5).


% Methods to call inorder to calculate paths and weights
% travel(Current, Goal, TrainStates, Record, Result).
travel(Start, Finish, States, Data) :-
    travel(Start, Finish, States, [], Data).
travel(Finish, Finish, _, _, Data) :-
    Data = [[], weight(0)].
travel(This, Finish, States, Record, Data) :-
    station(This, [Next, Train, Weight]),
    \+member(Next, Record),
    travel(Next, Finish, States, [This|Record], [Paths, weight(Score)]),
    member(train(Train, TrainState), States),
    modifier(TrainState, Modifier),
    NewScore is Score + Weight * Modifier,
    Data = [[take(Train, Next)|Paths], weight(NewScore)].

plans(Start, Finish, States, Plans) :-
    findall(Routes, travel(Start, Finish, States, Routes), Plans).


% Methods to find the shortest path measured by weight
shortestPath([], Output) :-
    Output = [[], weight(999)].
shortestPath([This|Rest], NewBest) :-
    shortestPath(Rest, Best),
    compareWeight(This, Best, NewBest).

compareWeight(This, Best, NewBest) :-
    This = [_, weight(ThisWeight)],
    Best = [_, weight(BestWeight)],
    (   ThisWeight > BestWeight
    ->  NewBest = Best
    ;   NewBest = This).


% Methods to write out the current situation.
writeStates(Train, Plan, Current) :-
    nl, write("Currently the rider is at station "), write(Current), write("."), nl, nl,
    write("The plan is..."), nl,
    writePlan(Plan),
    write("As of the trains..."), nl,
    writeTrain(Train), !.

writePlan([[], weight(Weight)]) :-
    write("Traveling weight: "), write(Weight), nl, nl.
writePlan([[This|Rest], Weight]) :-
    This = take(Train, Station),
    write("Take "), write(Train), write(" train to station "), write(Station), write("."), nl,
    writePlan([Rest, Weight]), !.

writeTrain([train(Train, State)]) :-
    write(Train), write(" train is currently "), write(State), write("."), nl, nl.
writeTrain([This|Rest]) :-
    This = train(Train, State),
    write(Train), write(" train is currently "), write(State), write("."), nl,
    writeTrain(Rest).

tips() :-
    write("Welcome..."), nl,
    findall(Trains, train(Trains), Result1),
    write("Available trains include: "), write(Result1), nl,
    findall(Modifiers, modifier(Modifiers, _), Result2),
    write("Available states include: "), write(Result2), nl,
    write("Acceptable inputs include: "), nl,
    write("next"), nl,
    write("Train NewState"), nl, nl.


% Stolen from Schlegel's blocks world.
read_word_list(Ws) :-
    read_line_to_codes(user_input, Cs),
    atom_codes(A, Cs),
    tokenize_atom(A, Ws).



% Main functions
start(Start, Goal) :-
    tips(),
    getTrainStates(TrainStates),
    loop(Start, Goal, TrainStates).

loop(Goal, Goal, _) :- write("Rider has reached the destination of station "), write(Goal), nl.
loop(Current, Goal, Trains) :-
    plans(Current, Goal, Trains, Plans),
    shortestPath(Plans, Plan),
    writeStates(Trains, Plan, Current),
    read_word_list(Input),
    (   Input = [next]
    ->  Plan = [[take(_, Next)|_], _],
        loop(Next, Goal, Trains)
    ;   Input = [Train, NewState]
    ->  updateTrainStates(Trains, train(Train, NewState), NewTrains),
        loop(Current, Goal, NewTrains)).

