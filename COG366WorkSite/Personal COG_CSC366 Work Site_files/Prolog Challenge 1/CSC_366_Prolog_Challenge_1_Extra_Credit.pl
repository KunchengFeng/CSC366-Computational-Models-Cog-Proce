% Facts.
sister(abigail).
sister(brenda).
sister(mary).
sister(paula).
sister(tara).

month(february).
month(march).
month(june).
month(july).
month(december).

day(sunday).
day(monday).
day(wednesday).
day(friday).
day(saturday).

weekday(monday).
weekday(wednesday).
weekday(friday).
weekend(saturday).
weekend(sunday).

% Functions to be used.
unique([First|Rest]) :- member(First, Rest), !, fail.
unique([_|Rest]) :- unique(Rest).
unique([_]).

advanceMonth(ThisMonth, TargetMonth) :- ThisMonth = TargetMonth.
advanceMonth(february, TargetMonth) :- advanceMonth(march, TargetMonth).
advanceMonth(march, TargetMonth) :- advanceMonth(june, TargetMonth).
advanceMonth(june, TargetMonth) :- advanceMonth(july, TargetMonth).
advanceMonth(july, TargetMonth) :- advanceMonth(december, TargetMonth).

earlier(ThisMonth, TargetMonth) :- ThisMonth = TargetMonth, !, fail.
earlier(ThisMonth, TargetMonth) :- advanceMonth(ThisMonth, TargetMonth).

show(Person, PersonMonth, PersonDay) :- write(Person), write(" was born in "), write(PersonMonth),
    write(" and on a "), write(PersonDay), nl.

% Function to be called.
solve :-
    % Declaring variables and make sure they are unique.
    month(AbiMonth), month(BreMonth), month(MaryMonth), month(PaulaMonth), month(TaraMonth),
    unique([AbiMonth, BreMonth, MaryMonth, PaulaMonth, TaraMonth]),

    day(AbiDay), day(BreDay), day(MaryDay), day(PaulaDay), day(TaraDay),
    unique([AbiDay, BreDay, MaryDay, PaulaDay, TaraDay]),

    Birthdays = [ birthday(abigail, AbiMonth, AbiDay),
                  birthday(brenda, BreMonth, BreDay),
                  birthday(mary, MaryMonth, MaryDay),
                  birthday(paula, PaulaMonth, PaulaDay),
                  birthday(tara, TaraMonth, TaraDay) ],

    % Hint #1.
       member(birthday(paula, march, _), Birthdays),
    \+ member(birthday(paula, _, saturday), Birthdays),
    \+ member(birthday(abigail, _, friday), Birthdays),
    \+ member(birthday(abigail, _, wednesday), Birthdays),

    % Hint #2.
    sister(MondayGirl),
    month(MondayGirlMonth),
    earlier(MondayGirlMonth, BreMonth),
    earlier(MondayGirlMonth, MaryMonth),
       member(birthday(MondayGirl, MondayGirlMonth, monday), Birthdays),

    % Hint #3.
    weekend(TaraDay),
    \+ member(birthday(tara, february, _), Birthdays),

    % Hint #4.
    weekend(MaryDay),
    \+ member(birthday(mary, december, _), Birthdays),
    sister(SundayGirl),
    unique([MondayGirl, SundayGirl]),
       member(birthday(SundayGirl, june, sunday), Birthdays),

    % Hint #5.
    earlier(TaraMonth, BreMonth),
    \+ member(birthday(brenda, _, friday), Birthdays),
    \+ member(birthday(mary, july, _), Birthdays),

    show(abigail, AbiMonth, AbiDay),
    show(brenda, BreMonth, BreDay),
    show(mary, MaryMonth, MaryDay),
    show(paula, PaulaMonth, PaulaDay),
    show(tara, TaraMonth, TaraDay).

