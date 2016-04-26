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
     readLine(LL,_), [C|LL] = L
    ).    

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
parseLine(L,P) :- P = L.

% Tape, State, Transitions, Result
simulateTS(T, S, Trs, R) :-
    S == 'F', true;
    getTransition(T, S, Trs, Tr),
    nth0(3, Tr, NS),
    nth0(4, Tr, A), 
    ( A == 'L', shiftLeft(T, S, NT);
      A == 'R', shiftRight(T, S, NT);
      writeSymbol(T, S, A, NT)
    ),
    simulateTS(NT, NS, Trs, R2),
    R = [NT|R2].

% Tape, State, Transitions, Transition
getTransition(T, S, [H|Trs], Tr) :-
    nth0(I, T, S),
    J is I + 1,
    nth0(J, T, A),
    (nth0(0, H, X), X == S, 
     nth0(1, H, Y), Y == A, Tr = H;
     getTransition(T, S, Trs, Tr)
    ).


% http://stackoverflow.com/questions/8519203/prolog-replace-an-element-in-a-list-at-a-specified-index
replace([_|T], 0, X, [X|T]).
replace([H|T], I, X, [H|R]):- I > -1, NI is I-1, replace(T, NI, X, R), !.
replace(L, _, _, L).

writeSymbol(T, S, A, R) :-
    nth0(I, T, S),
    J is I + 1,
    replace(T, J, A, R).

% check na abnormalni zastaveni
shiftLeft(T, S, R) :- 
    nth0(I, T, S),
    J is I - 1,
    nth0(J, T, Tmp),
    replace(T, J, S, X),
    replace(X, I, Tmp, R).   

% check na blank
shiftRight(T, S, R) :- 
    nth0(I, T, S),
    J is I + 1,
    nth0(J, T, Tmp),
    replace(T, J, S, X),
    replace(X, I, Tmp, R).   

main :- 
    prompt(_,''),
    readLines(LL),
    parseLines(LL, LP),
    last(LP,T),
    delete(LP,T,Trs),
    append(['S'], T, ST),
    write(ST),
    simulateTS(ST, 'S', Trs, R),
    halt.



% vim: expandtab:shiftwidth=4:tabstop=4:softtabstop=0:textwidth=120

