% Project: Turing Machine
% Course:  Funcional and Logical Programming
% Author:  Tomas Bruckner, xbruck02@stud.fit.vutbr.cz
% Date:	   2016-04-26
%

% Reads every line from stdin
readLines(Lines) :-
    readLine(Line,Char),
    ( isEOFEOL(Char), Lines = [];
    readLines(RestLines), Lines = [Line|RestLines]).

% Reads single line
readLine(Line, Char) :-
    get_char(Char),
    (isEOFEOL(Char), Line = [], !;
     readLine(RestChars,_), [Char|RestChars] = Line
    ).

% Checks for EOF or EOL
isEOFEOL(Char) :-
    Char == end_of_file;
    (char_code(Char,Code), Code == 10).

% Parses every lines to tape format or transition format
parseLines([],[]).
parseLines([Line|RestLines], [ParsedLine|ParsedLines]) :-
    parseLines(RestLines,ParsedLines), parseLine(Line,ParsedLine).

% Parses single line
% tape "symbolsymbolsymbolsymbol"
% transition "oldstate symbol newstate action"
parseLine(Line,Parsed) :-
    nth0(0, Line, OldState),
    nth0(2, Line, Symbol),
    nth0(4, Line, NewState),
    nth0(6, Line, Action),
    Parsed = [OldState, Symbol, NewState, Action].
parseLine(Line,Parsed) :- Parsed = Line.

% Simulates Turing Machine
simulateTS(Tape, State, Transitions, Output) :-
    State == 'F', Output = [];

    getTransition(Tape, State, Transitions, SingleTransition),
    nth0(2, SingleTransition, NewState),
    nth0(3, SingleTransition, Action),
    ( Action == 'L', shiftLeft(Tape, State, NewTape);
      Action == 'R', shiftRight(Tape, State, NewTape);
      writeSymbol(Tape, State, Action, NewTape)
    ),
    changeState(NewTape, State, NewState, FNewTape),
    simulateTS(FNewTape, NewState, Transitions, RestOutput),
    Output = [FNewTape|RestOutput].

% Gets transition for current state and symbol on head
getTransition(_, _, [], []).
getTransition(Tape, State, [CurrentTransition|Transitions], OutputTransition) :-
    nth0(StateIndex, Tape, State),
    SymbolIndex is StateIndex + 1,
    nth0(SymbolIndex, Tape, Symbol),
    (nth0(0, CurrentTransition, TransitionState),
     TransitionState == State,
     nth0(1, CurrentTransition, TransitionSymbol),
     TransitionSymbol == Symbol,
     OutputTransition = CurrentTransition ;

     getTransition(Tape, State, Transitions, OutputTransition)
    ).

% Changes state on tape
changeState(Tape, OldState, NewState, NewTape) :-
    nth0(StateIndex, Tape, OldState), replace(Tape, StateIndex, NewState, NewTape).

% Replaces element in list at specified index
% http://stackoverflow.com/questions/8519203/prolog-replace-an-element-in-a-list-at-a-specified-index
replace([_|RestElements], 0, NewElement, [NewElement|RestElements]).
replace([FirstElement|RestOriginalElements], Index, NewElement, [FirstElement|RestElements]):- 
    Index > -1,
    NewIndex is Index - 1,
    replace(RestOriginalElements, NewIndex, NewElement, RestElements), !.
replace(List, _, _, List).

% Writes speicified symbol on tape at head location
writeSymbol(Tape, State, Symbol, NewTape) :-
    nth0(StateIndex, Tape, State),
    SymbolIndex is StateIndex + 1,
    replace(Tape, SymbolIndex, Symbol, NewTape).

% Shifts head to the left
shiftLeft(Tape, State, NewTape) :-
    nth0(StateIndex, Tape, State),
    NewStateIndex is StateIndex - 1,
    (NewStateIndex < 0, writef("Abnormal halt!\n"),halt;
     nth0(NewStateIndex, Tape, Tmp),
     replace(Tape, NewStateIndex, State, TmpTape),
     replace(TmpTape, StateIndex, Tmp, NewTape)
    ).

% Shifts head to the right
shiftRight(Tape, State, NewTape) :-
    nth0(StateIndex, Tape, State),
    NewStateIndex is StateIndex + 1,
    length(Tape, Len),
    HighestIndex is Len - 1,
    (NewStateIndex == HighestIndex, append(Tape, [' '], TmpTape);
     TmpTape = Tape
    ),
    nth0(NewStateIndex, TmpTape, Tmp),
    replace(TmpTape, NewStateIndex, State, TmpTape2),
    replace(TmpTape2, StateIndex, Tmp, NewTape).

% Writes configurations after simmulation
writeConfigurations([]).
writeConfigurations([Configuration|RestConfigurations]) :-
    writef("%s\n", [Configuration]), writeConfigurations(RestConfigurations).

% Starting point, parses Turing Machine from stdin
% TS format:
% <state><space><symbol><space><newstate><space><symbol/L/R>
% <symbol><symbol><symbol>...
main :-
    prompt(_,''),
    readLines(Lines),
    parseLines(Lines, LinesParsed),
    last(LinesParsed,Tape),
    delete(LinesParsed,Tape,Transitions),
    append(['S'], Tape, StartingTape),
    !,
    ( simulateTS(StartingTape, 'S', Transitions, Configurations);
      writef("Abnormal halt!"), halt
    ),
    writeConfigurations(Configurations).

% vim: expandtab:shiftwidth=4:tabstop=4:softtabstop=0:textwidth=120
