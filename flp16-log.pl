% Project: Turing Machine
% Course:  Funcional and Logical Programming
% Author:  Tomas Bruckner, xbruck02@stud.fit.vutbr.cz
% Date:	   2016-04-26
%
main :- 
    prompt(_,''),
    readLines(LL),
    write(LL),
    halt
.


readLine(L, C) :-
    get_char(C),
    (isEOFEOL(C), L = [], !;
        readLine(LL,_), 
        [C|LL] = L).    

isEOFEOL(C) :-
    C == end_of_file;
    (char_code(C,Code), Code==10).

readLines(LL) :-
    readLine(L,C),
    ( isEOFEOL(C), LL = [];
    readLines(LLL), LL = [L|LLL]).

% vim: expandtab:shiftwidth=4:tabstop=4:softtabstop=0:textwidth=120

