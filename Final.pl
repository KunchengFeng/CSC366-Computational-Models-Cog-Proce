% Leprechauns
leprechanu(georgie).
leprechanu(lucky).
leprechaun(tricky).
leprechaun(freckles).
leprechaun(tiny).
leprechaun(paddy).

% Children
child(amber).
child(david).
child(sarah).
child(nick).
child(izzy).
child(sam).

% Wishes
wish(money).
wish("3 more wishes").
wish("lots of desserts").
wish("a horse").
wish("a castle").
wish("good grades").

% No duplicates.
unique([First|Rest]) :- member(First, Rest), !, fail.
unique([_|Rest]) :- unique(Rest).
unique([_]).

% Show result.
show([]).
show([This|Rest]) :-
    This = granted(Leprechaun, Child, Wish),
    write("Leprechaun "), write(Leprechaun),
    write(" granted "), write(Child),
    write("'s wish of "), write(Wish), write("."), nl,
    show(Rest).



solve :-
    child(Ge_Target), child(Lu_Target), child(Tr_Target),
    child(Fr_Target), child(Ti_Target), child(Pa_Target),
    unique([Ge_Target, Lu_Target, Tr_Target, Fr_Target, Ti_Target, Pa_Target]),

    wish(Ge_Gift), wish(Lu_Gift), wish(Tr_Gift),
    wish(Fr_Gift), wish(Ti_Gift), wish(Pa_Gift),
    unique([Ge_Gift, Lu_Gift, Tr_Gift, Fr_Gift, Ti_Gift, Pa_Gift]),

    % Relations.
    Relations = [ granted(georgie, Ge_Target, Ge_Gift),
                  granted(lucky, Lu_Target, Lu_Gift),
                  granted(tricky, Tr_Target, Tr_Gift),
                  granted(freckles, Fr_Target, Fr_Gift),
                  granted(tiny, Ti_Target, Ti_Gift),
                  granted(paddy, Pa_Target, Pa_Gift) ],


    % Hint #1.
    \+ member(granted(lucky, david, _), Relations),
    \+ member(granted(lucky, izzy, _), Relations),

    % Hint #2.
    member(granted(georgie, _, "good grades"), Relations),

    % Hint #3.
    \+ member(granted(_, sarah, "a castle"), Relations),
    \+ member(granted(_, sam, "a castle"), Relations),

    % Hint #4.
    \+ member(granted(freckles, nick, money), Relations),

    % Hint #5.
    \+ member(granted(paddy, amber, _), Relations),
    member(granted(paddy, _, "3 more wishes"), Relations),

    % Hint #6.
    member(granted(_, izzy, "lots of desserts"), Relations),

    % Hint #7.
    member(granted(lucky, sarah, "a horse"), Relations),

    % Hint #8.
    member(granted(tiny, sam, _), Relations),

    show(Relations).
