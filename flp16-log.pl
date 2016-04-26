% Project: Turing Machine
% Course:  Funcional and Logical Programming
% Author:  Tomas Bruckner, xbruck02@stud.fit.vutbr.cz
% Date:	   2016-04-26
%

readLines(LL) :-
    readLine(L,C),
    ( isEOFEOL(C), LL = [];
    readLines(LLL), LL = [L|LLL]).

readLine(L, C) :-
    get_char(C),
    (isEOFEOL(C), L = [], !;
        readLine(LL,_), 
        [C|LL] = L).    

isEOFEOL(C) :-
    C == end_of_file;
    (char_code(C,Code), Code==10).


% Parse all lines
parseLines([],[]).
parseLines([H|L], [H2|P]) :-
    parseLines(L,P), parseLine(H,H2).

% Parse single line
% tape "symbolsymbolsymbolsymbol"
% transition "oldstate symbol newstate action"
parseLine(L,P) :- 
    nth0(0, L, OS),
    nth0(2, L, S),
    nth0(4, L, NS),
    nth0(6, L, A),
    P = [OS, S, NS, A].

parseLine(L,P) :- atom_chars(P, L).

main :- 
    prompt(_,''),
    readLines(LL),
    parseLines(LL, LP),
    write(LP),
    halt.


% vim: expandtab:shiftwidth=4:tabstop=4:softtabstop=0:textwidth=120

