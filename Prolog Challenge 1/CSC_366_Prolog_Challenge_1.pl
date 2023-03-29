% Facts.
contestants(joanne).
contestants(lou).
contestants(ralph).
contestants(winnie).

animal("grizzly bear").
animal(moose).
animal(seal).
animal(zebra).

adventure(circus).
adventure("rock band").
adventure(spaceship).
adventure(train).

% If the head of the list is in the tail, fail.
all_different([Head|Tail]) :- member(Head, Tail), !, fail.
% Otherwise, check the tail of the list.
all_different([_|Tail]) :- all_different(Tail).
% If there's only one thing in the list, it's fine.
all_different([_]).

show(Contestant, Animal, Adventure) :- write(Contestant), write("'s friend "), write(Animal),
    write(" went to the "), write(Adventure), write(".\n").

solve :-
    animal(JoanneFriend), animal(LouFriend), animal(RalphFriend), animal(WinnieFriend),
    all_different([JoanneFriend, LouFriend, RalphFriend, WinnieFriend]),

    adventure(JoanneAdventure), adventure(LouAdventure),
    adventure(RalphAdventure), adventure(WinnieAdventure),
    all_different([JoanneAdventure, LouAdventure, RalphAdventure, WinnieAdventure]),

    Stories = [ story(joanne, JoanneFriend, JoanneAdventure),
                story(lou, LouFriend, LouAdventure),
                story(ralph, RalphFriend, RalphAdventure),
                story(winnie, WinnieFriend, WinnieAdventure)],

    % 1). The seal condition.
    \+ member(story(joanne, seal, _), Stories),
    \+ member(story(lou, seal, _), Stories),
    \+ member(story(_, seal, spaceship), Stories),
    \+ member(story(_, seal, train), Stories),

    % 2). Joanne's friend's condition
    \+ member(story(joanne, "grizzly bear", _), Stories),
       member(story(joanne, _, circus), Stories),

    % 3). Winnie's friend's condition.
       member(story(winnie, zebra, _), Stories),

    % 4). Grizzly bear's condition.
    \+ member(story(_,  "grizzly bear", spaceship), Stories),

    show(joanne, JoanneFriend, JoanneAdventure),
    show(lou, LouFriend, LouAdventure),
    show(ralph, RalphFriend, RalphAdventure),
    show(winnie, WinnieFriend, WinnieAdventure).
