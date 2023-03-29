% Solution to the It's a Tie logic puzzle.

% Facts
tie(cupids).
tie(happy_faces).
tie(leprechauns).
tie(reindeer).

mr(crow).
mr(evans).
mr(hurley).
mr(speigler).

relative(daughter).
relative(father_in_law).
relative(sister).
relative(uncle).


solve :-
    relative(CrowRelative), relative(EvansRelative), relative(HurleyRelative),
    relative(SpeiglerRelative),
    all_different([CrowRelative, EvansRelative, HurleyRelative, SpeiglerRelative]),
    
    tie(CrowTie), tie(EvansTie), tie(HurleyTie), tie(SpeiglerTie),
    all_different([CrowTie, EvansTie, HurleyTie, SpeiglerTie]),
    
    
            
    Gifts = [ gift(crow, CrowRelative, CrowTie),
              gift(evans, EvansRelative, EvansTie),
              gift(hurley, HurleyRelative, HurleyTie),
              gift(speigler, SpeiglerRelative, SpeiglerTie) ],
              
              
    % 1. The tie with the grinning leprechauns wasn't a present from a daughter.
    \+ member(gift(_, daughter, leprechauns), Gifts),
    
    % 2. Mr. Crow's tie features neither the dancing reindeer nor the yellow happy faces.
    \+ member(gift(crow, _, reindeer), Gifts),
    \+ member(gift(crow, _, happy_faces), Gifts),
    
    % 3. Mr. Speigler's tie wasn't a present from his uncle.
    \+ member(gift(speigler, uncle, _), Gifts),
    
    % 4. The tie with the yellow happy faces wasn't a gift from a sister.
    \+ member(gift(_, sister, happy_faces), Gifts),
    
    % 5. Mr Evans and Mr. Speigler own the tie with the grinning leprechauns
    %    and the tie that was a present from a father-in-law, in some order.
    (( member(gift(evans, _, leprechauns), Gifts),
       member(gift(speigler, father_in_law, _), Gifts) ) ;
     ( member(gift(speigler, _, leprechauns), Gifts),
       member(gift(evans, father_in_law, _), Gifts) ) ),
    
    % 6. Mr. Hurley received his flamboyant tie from his sister.
    member(gift(hurley, sister, _), Gifts), 
    
    tell(crow, CrowRelative, CrowTie),
    tell(evans, EvansRelative, EvansTie),
    tell(hurley, HurleyRelative, HurleyTie),
    tell(speigler, SpeiglerRelative, SpeiglerTie).
    
tell(To, From, Tie) :- write('Mr. '), write(To), write(' got the '), write(Tie),
    write(' tie from his '), write(From), write('.'), nl.
    
% If the head of the list is in the tail, fail.
all_different([Head|Tail]) :- member(Head, Tail), !, fail.
% Otherwise, check the tail of the list.
all_different([_|Tail]) :- all_different(Tail).
% If there's only one thing in the list, it's fine.
all_different([_]).