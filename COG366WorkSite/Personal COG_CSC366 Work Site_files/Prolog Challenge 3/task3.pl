% Model

% Facts

block(b1).
block(b2).
block(b3).
block(b4).
block(b5).
block(b6).
block(b7).
block(b8).

size(b1, large).
size(b2, large).
size(b3, large).
size(b4, large).
size(b5, small).
size(b6, small).
size(b7, small).
size(b8, small).

color(b1, yellow).
color(b2, red).
color(b3, blue).
color(b4, green).
color(b5, yellow).
color(b6, red).
color(b7, blue).
color(b8, green).

initial_state([on(b1, table), on(b2, table), on(b3, table), on(b4, table), on(b5, table),
    on(b6, table), on(b7, table), on(b8, table)]).

% Rules
clear(Block, State) :- \+ member(on(_, Block), State).
empty_hand(State) :- \+ member(hand(_), State).
holding(State, Block) :- member(hand(Block), State).
is_on(Block1, Block2, State) :- member(on(Block1, Block2), State).

validate(pickup, Block, State) :-
    clear(Block, State), empty_hand(State).
validate(put, Block, table) :-
    clear(Block, State), (empty_hand(State) ; holding(State, Block)).
validate(unstack, Block, State) :-
    clear(Block, State), empty_hand(State).


validate(pickup, Block1, Block2, State) :-
    clear(Block1, State), is_on(Block1, Block2, State), empty_hand(State).
validate(put, Block1, Block2, State) :-
    clear(Block1, State), clear(Block2, State), (empty_hand(State) ; holding(State, Block1)).
validate(stack, Block1, Block2, State) :-
    clear(Block1, State), clear(Block2, State), (empty_hand(State) ; holding(State, Block1)).
validate(unstack, Block1, Block2, State) :-
    clear(Block1, State), is_on(Block1, Block2, State), empty_hand(State).

perform(pickup, Block, State, NewState) :-
    replace(on(Block,_), hand(Block), State, NewState).
perform(unstack, Block, State, NewState) :-
    replace(on(Block,_), hand(Block), State, NewState).
perform(put, Block1, Target, State, NewState) :-
    perform(pickup, Block1, State, State1),
    replace(hand(Block1), on(Block1, Target), State1, NewState).
perform(stack, Block1, Target, State, NewState) :-
    perform(pickup, Block1, State, State1),
    replace(hand(Block1), on(Block1, Target), State1, NewState).



% NLP

% Parsing

sentence(s(VP)) --> verb_phrase(VP).
sentence(s(VP)) --> verb_phrase(VP), dot.
noun_phrase(np(Det, Noun)) --> det(Det), noun(Noun).
noun_phrase(np(Det, Adjp, Noun)) --> det(Det), adj_phrase(Adjp), noun(Noun).
verb_phrase(vp(Verb, NP)) --> verb(Verb), noun_phrase(NP).
verb_phrase(vp(Verb, NP, PP)) --> verb(Verb), noun_phrase(NP), prep_phrase(PP).
prep_phrase(pp(Prep, NP)) --> prep(Prep), noun_phrase(NP).
adj_phrase(adjp(Adj)) --> adj(Adj).
adj_phrase(adjp(Adj, Adjp)) --> adj(Adj), adj_phrase(Adjp).
verb(v(put)) --> [put].
verb(v(pickup)) --> [pickup].
verb(v(stack)) --> [stack].
verb(v(unstack)) --> [unstack].
det(d(the)) --> [the].
adj(a(large)) --> [large].
adj(a(small)) --> [small].
adj(a(green)) --> [green].
adj(a(red)) --> [red].
adj(a(yellow)) --> [yellow].
adj(a(blue)) --> [blue].
noun(n(block)) --> [block].
noun(n(table)) --> [table].
prep(p(on)) --> [on].
prep(p(from)) --> [from].
dot --> ['.'].

% Extracting Verbs and NPs

extract(s(vp(v(Verb), NounPhrase)), Verb, NounPhrase).
extract(s(vp(v(Verb), NounPhrase1, pp(_, NounPhrase2))), Verb, NounPhrase1, NounPhrase2).

% Reference Resolution

% Stacking context
resolve_ref(NP1, NP2, State, Block1, Block2) :-
    NP1 = np(_, adjp(a(Adj1)), n(block)),
    NP2 = np(_, adjp(a(Adj2)), n(block)),
    is_on(Block1, Block2, State),
    (   size(Block1, Adj1) ; color(Block1, Adj1)),
    (   size(Block2, Adj2) ; color(Block2, Adj2)).

% 2-adjective
resolve_ref(NP, _, Block) :-
    NP = np(_, adjp(a(Size), adjp(a(Color))), n(block)),
    size(Block, Size), color(Block, Color).
resolve_ref(NP, _, Block) :-
    NP = np(_, adjp(a(Color), adjp(a(Size))), n(block)),
    size(Block, Size), color(Block, Color).

% 0-adjective
resolve_ref(NP, State, Block) :- NP = np(d(the), n(block)), member(hand(Block), State).
resolve_ref(NP, _, table) :- NP = np(d(the), n(table)).

% Natural Language Generation

nlg(Block) :- size(Block, S), color(Block, C), write("the "), write(S), write(" "),
    write(C), write(" block").
nlg(table) :- write("the table").
nlg(on(Block, Target)) :- nlg(Block), write(" is on "), nlg(Target), nl.
nlg(hand(Block)) :- nlg(Block), write(" is in the hand "), nl.

nlg([StateItem]) :- nlg(StateItem), !.
nlg([StateItem|Rest]) :- nlg(StateItem), nlg(Rest), !.

% Main Loop
talktome :- initial_state(State), write("Right now..."), nl, nlg(State), !, talktome(State).
talktome(State) :- write("Waiting for next inputs..."), nl, !, get_input(State).

get_input(State) :-
    read_word_list(Input), !,
    check_input(Input, State).

check_input(Input, _) :-
    (Input = [exit] ; Input = [exit, '.']), !, fail.
check_input(Input, State) :-
    sentence(Parse, Input, []),
    !, perform_input(Parse, State).
check_input(_, State) :-
    write("Error, can't understand the input."), nl, !, talktome(State).

perform_input(Parse, State) :-
    extract(Parse, Verb, NP),
    resolve_ref(NP, State, Block),
    validate(Verb, Block, State),
    perform(Verb, Block, State, NewState),
    write("Right now..."), nl, nlg(NewState),
    !, talktome(NewState).
perform_input(Parse, State) :-
    extract(Parse, Verb, NP1, NP2),
    ((resolve_ref(NP1, State, Block1), resolve_ref(NP2, State, Block2)) ;
      resolve_ref(NP1, NP2, State, Block1, Block2)),
    validate(Verb, Block1, Block2, State),
    (perform(Verb, Block1, State, NewState) ; perform(Verb, Block1, Block2, State, NewState)),
    write("Right now..."), nl, nlg(NewState),
    !, talktome(NewState).
perform_input(_, State) :-
    write("Error, failed to resolve reference."), nl, !, talktome(State).


% Planning
%
% When plan function is called, it first takes in the inital state and
% the goal state, then it tries to find an block to perform the
% stacking operations on. The block that is directily on the table
% in both the inital state and the goal state will be chosen.
%
% Then with each recursion, it will try to stack some other block on the
% current block in order to match the goal state, the other block that
% just got put on top will be the new active block and pass down to the
% new recursion.
%
% If the current block have nothing on top in the goal state, it will
% try to see if the current state has reached goal state yet, if not it
% will try to find a new active block to perform recursion on.
%
% Starting case.
plan(State, Goal, Steps) :-
    is_on(Block, table, Goal),
    is_on(Block, table, State),
    plan(State, Goal, Steps, Block).

% Recursions and end case.
plan(State, Goal, Steps, _) :-
    is_same(State, Goal), Steps = [], !.
plan(State, Goal, Steps, ActiveBlock) :-
    is_on(OtherBlock, ActiveBlock, Goal),
    clear(ActiveBlock, State),
    validate(stack, OtherBlock, ActiveBlock, State),
    perform(stack, OtherBlock, ActiveBlock, State, NewState),
    !, plan(NewState, Goal, RestOfSteps, OtherBlock),
    Steps = [stack(OtherBlock, on(ActiveBlock)) | RestOfSteps].
% Current block reach the top, find a new active block.
plan(State, Goal, Steps, ActiveBlock) :-
    clear(ActiveBlock, Goal),
    is_on(NewBlock, table, Goal),
    is_on(NewBlock, table, State),
    clear(NewBlock, State),
    !, plan(State, Goal, Steps, NewBlock).

% In prolog list order matters.
is_same([Element], List) :- member(Element, List).
is_same([Head|Tail], List) :- member(Head, List), is_same(Tail, List).

% Temp data
goal_0([on(b1, table), on(b2, b3), on(b3, b1), on(b4, b5), on(b5, b6), on(b6, table), on(b7, b4), on(b8, b7)]).
goal_1([on(b2, table), on(b3, b2), on(b4, b3), on(b1, b4), on(b8, b7), on(b7, table), on(b6, b8), on(b5, b6)]).
goal_2([on(b1, b3), on(b2, b4), on(b3, table), on(b4, table), on(b5, b1), on(b6, b5), on(b7, b8), on(b8, table)]).
goal_3([on(b1, b2), on(b2, table), on(b3, table), on(b4, b3), on(b5, b4), on(b6, b5), on(b7, b6), on(b8, b7)]).


% Utilities

replace(_, _, [], []).
replace(O, R, [O|T], [R|T2]) :- replace(O, R, T, T2).
replace(O, R, [H|T], [H|T2]) :- dif(H,O), replace(O, R, T, T2).

find_in(Pattern, [H|_], Result) :- Pattern = H, Result = H.
find_in(Pattern, [_|R], Result) :- find_in(Pattern, R, Result).
find_in(_, [], _) :- fail.

read_word_list(Ws) :-
    read_line_to_codes(user_input, Cs),
    atom_codes(A, Cs),
    tokenize_atom(A, Ws).
