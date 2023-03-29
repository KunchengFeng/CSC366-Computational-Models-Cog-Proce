% Stations
% Station(ThisStation, Connections) :-
%         Connections = [NextStation, Train, Weight].
station(1, Connections) :-
    Connections = [2, a, 1];
    Connections = [6, a, 1.5];
    Connections = [9, b, 1];
    Connections = [8, b, 1].
station(2, Connections) :-
    Connections = [1, a, 1];
    Connections = [3, a, 1.5];
    Connections = [9, e, 1];
    Connections = [17, f, 2];
    Connections = [20, e, 1];
    Connections = [21, f, 1].
station(3, Connections) :-
    Connections = [22, f, 1];
    Connections = [23, f, 1];
    Connections = [23, d, 1];
    Connections = [4, d, 2.5];
    Connections = [4, a, 2.5];
    Connections = [2, a, 1.5].
station(4, Connections) :-
    Connections = [3, a, 2.5];
    Connections = [3, d, 2.5];
    Connections = [15, d, 1];
    Connections = [5, a, 1].
station(5, Connections) :-
    Connections = [4, a, 1];
    Connections = [15, c, 1];
    Connections = [14, c, 1];
    Connections = [6, a, 1.5].
station(6, Connections) :-
    Connections = [5, a, 1.5];
    Connections = [13, c, 1];
    Connections = [12, b, 1];
    Connections = [12, c, 1];
    Connections = [7, b, 1];
    Connections = [1, a, 1.5].

station(7, Connections) :-
    Connections = [8, b, 1];
    Connections = [6, b, 1].
station(8, Connections) :-
    Connections = [7, b, 1];
    Connections = [1, b, 1].
station(9, Connections) :-
    Connections = [1, b, 1];
    Connections = [2, e, 1];
    Connections = [10, b, 1];
    Connections = [12, e, 1.5].
station(10, Connections) :-
    Connections = [9, b, 1];
    Connections = [11, b, 1].
station(11, Connections) :-
    Connections = [10, b, 1];
    Connections = [12, b, 1].
station(12, Connections) :-
    Connections = [6, b, 1];
    Connections = [6, c, 1];
    Connections = [9, e, 1.5];
    Connections = [11, b, 1];
    Connections = [16, c, 1];
    Connections = [16, e, 1].

station(13, Connections) :-
    Connections = [6, c, 1];
    Connections = [14, c, 1].
station(14, Connections) :-
    Connections = [5, c, 1];
    Connections = [13, c, 1].
station(15, Connections) :-
    Connections = [4, d, 1];
    Connections = [5, c, 1];
    Connections = [16, c, 1];
    Connections = [25, d, 1].
station(16, Connections) :-
    Connections = [12, c, 1];
    Connections = [12, e, 1];
    Connections = [15, c, 1];
    Connections = [17, e, 1].

station(17, Connections) :-
    Connections = [2, f, 2];
    Connections = [16, e, 1];
    Connections = [18, e, 1];
    Connections = [26, f, 1].
station(18, Connections) :-
    Connections = [17, e, 1];
    Connections = [19, e, 1].
station(19, Connections) :-
    Connections = [18, e, 1];
    Connections = [20, e, 1].
station(20, Connections) :-
    Connections = [19, e, 1];
    Connections = [2, e, 1].

station(21, Connections) :-
    Connections = [2, f, 1];
    Connections = [22, f, 1].
station(22, Connections) :-
    Connections = [21, f, 1];
    Connections = [3, f, 1].
station(23, Connections) :-
    Connections = [3, f, 1];
    Connections = [3, d, 1];
    Connections = [23, f, 1];
    Connections = [23, d, 1].
station(24, Connections) :-
    Connections = [23, f, 1];
    Connections = [23, d, 1].
station(25, Connections) :-
    Connections = [15, d, 1];
    Connections = [24, f, 1];
    Connections = [24, d, 1];
    Connections = [26, f, 1].
station(26, Connections) :-
    Connections = [17, f, 1];
    Connections = [25, f, 1].



% Train stuffs
train(Trains) :-
    Trains = [a, b, c, d, e, f].
generateTrainStates([], []).
generateTrainStates([This|Rest], States) :-
    generateTrainStates(Rest, RestStates),
    States = [train(This, normal)|RestStates].
getTrainStates(TrainStates) :-
    train(Trains),
    generateTrainStates(Trains, TrainStates).

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
% modifier(broken) is hardcoded in method travel(_, _, _, _), one listed
% here is only for the quick tip.
modifier(fast, 0.5).
modifier(normal, 1).
modifier(slow, 1.5).
modifier(broken, 0).


% Methods to call inorder to calculate paths and weights
% travel(RiderState, TrainStates, Record, Result).
% warning: TrainStates != TrainState
travel(RiderState, TrainStates, Data) :-
    travel(RiderState, TrainStates, [], Data).
travel([Goal, Goal, _], _, _, Data) :-
    Data = [[], weight(0)].
travel(RiderState, TrainStates, Record, Data) :-
    RiderState = [This, Goal, Train],
    station(This, [Next, NextTrain, Weight]),
    \+member(Next, Record),
    travel([Next, Goal, NextTrain], TrainStates, [This|Record], [Paths, weight(Score)]),
    member(train(NextTrain, TrainState), TrainStates),
    TrainState \= broken,
    modifier(TrainState, Modifier),
    (   NextTrain \= Train
    ->  NewScore is Score + Weight * Modifier + 1
    ;   NewScore is Score + Weight * Modifier),
    Data = [[take(NextTrain, Next)|Paths], weight(NewScore)].

plans(RiderState, TrainStates, Plans) :-
    findall(Routes, travel(RiderState, TrainStates, Routes), Plans).


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

% Helpful starting message.
tips() :-
    write("Welcome..."), nl,
    train(Trains),
    write("Available trains include: "), write(Trains), nl,
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
    loop([Start, Goal, z], TrainStates).

% End case
loop([Goal, Goal, _], _) :- write("Rider has reached the destination of station "), write(Goal), nl.
% Normal case
loop(RiderState, TrainStates) :-
    plans(RiderState, TrainStates, Plans),
    shortestPath(Plans, Plan),
    Plan = [Path, _], Path \= [],
    RiderState = [Current, Goal, _],
    writeStates(TrainStates, Plan, Current),
    read_word_list(Input),
    (   Input = [next]
    ->  Plan = [[take(Train, Next)|_], _],
        loop([Next, Goal, Train], TrainStates);

        Input = [Train, NewState]
    ->  updateTrainStates(TrainStates, train(Train, NewState), NewTrains),
        loop(RiderState, NewTrains);

        write("Invalid input..."), nl,
        loop(RiderState, TrainStates)).

% Stuck case
loop(RiderState, TrainStates) :-
    RiderState = [_, Goal, _],
    write("Rider currently have no way to reach his destination of station "), write(Goal), nl,
    read_word_list(Input),
    (   Input = [next]
    ->  write("Rider don't know where to go..."), nl,
        loop(RiderState, TrainStates);

        Input = [Train, NewState]
    ->  updateTrainStates(TrainStates, train(Train, NewState), NewTrains),
        loop(RiderState, NewTrains);

        write("Invalid input..."), nl,
        loop(RiderState, TrainStates)).

