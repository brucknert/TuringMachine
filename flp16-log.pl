% Project: Turing Machine
% Course:  Funcional and Logical Programming
% Author:  Tomas Bruckner, xbruck02@stud.fit.vutbr.cz
% Date:	   2016-04-26


% Starting point, parses Turing Machine from stdin
% TS transition format:
% <state><space><symbol><space><newstate><space><symbol/L/R>
% TS tape format:
% <symbol><symbol><symbol>...
main :-
    prompt(_,''),
    readLines(Lines),
    last(Lines, Tape),
    delete(Lines, Tape, PreparsedTransitions),
    parseTransitions(PreparsedTransitions, Transitions),
    append(['S'], Tape, StartingTape),
    !,
    ids(0, StartingTape, 'S', Transitions, Configurations),
    append([StartingTape], Configurations, FinalConfigurations),
    writeConfigurations(FinalConfigurations),
    halt.

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

% Parses every lines to transition format
parseTransitions([],[]).
parseTransitions([Line|RestLines], [ParsedLine|ParsedLines]) :-
    parseTransition(Line,ParsedLine), parseTransitions(RestLines,ParsedLines).

% Parses single line
% transition "oldstate symbol newstate action"
parseTransition(Line,Parsed) :-
    nth0(0, Line, OldState),
    nth0(2, Line, Symbol),
    nth0(4, Line, NewState),
    nth0(6, Line, Action),
    Parsed = [OldState, Symbol, NewState, Action].

% Indicates if we should continue with next iteration of Iterative Depth Search
:- dynamic continue/0.

% Iterative Depth Search
ids(Level, Tape, State, Transitions, Output) :- 
    % Final state found in specified depth
    simulateTS(Level, Tape, State, Transitions, Output); 
    % Final state can still be in higher depth
    continue, retract(continue), NewLevel is Level + 1, ids(NewLevel, Tape, State, Transitions, Output);
    % There are no valid transitions
    writef("Abnormal halt!\n"), halt.

% Simulates Turing Machine
simulateTS(0, _, S, _, Output) :- asserta(continue), S == 'F', Output = [], !.
simulateTS(Level, Tape, State, Transitions, Output) :-
    % not in final state
    Level > 0,
    getTransition(Tape, State, Transitions, SingleTransition),
    nth0(2, SingleTransition, NewState),
    nth0(3, SingleTransition, Action),
    ( Action == 'L', shiftLeft(Tape, State, NewTape);
      Action == 'R', shiftRight(Tape, State, NewTape);
      writeSymbol(Tape, State, Action, NewTape) 
    ),
    changeState(NewTape, State, NewState, FNewTape),
    NewLevel is Level - 1,
    simulateTS(NewLevel, FNewTape, NewState, Transitions, RestOutput),
    % all configurations
    Output = [FNewTape|RestOutput].

% Gets transition for current state and symbol on head
getTransition(_, _, [], Output) :- Output = [].
getTransition(Tape, State, [CurrentTransition|Transitions], OutputTransition) :-
    nth0(StateIndex, Tape, State),
    SymbolIndex is StateIndex + 1,
    nth0(SymbolIndex, Tape, Symbol),
    ( nth0(0, CurrentTransition, TransitionState),
      TransitionState == State,
      nth0(1, CurrentTransition, TransitionSymbol),
      TransitionSymbol == Symbol,
      OutputTransition = CurrentTransition ;
     % CurrentTransition is not valid for state and symbol under head, we must continue searching
     getTransition(Tape, State, Transitions, OutputTransition)
    ).

% Shifts head to the left
shiftLeft(Tape, State, NewTape) :-
    nth0(StateIndex, Tape, State),
    NewStateIndex is StateIndex - 1,
    nth0(NewStateIndex, Tape, Tmp),
    replace(Tape, NewStateIndex, State, TmpTape),
    replace(TmpTape, StateIndex, Tmp, NewTape).

% Shifts head to the right
shiftRight(Tape, State, NewTape) :-
    nth0(StateIndex, Tape, State),
    NewStateIndex is StateIndex + 1,
    length(Tape, Len),
    HighestIndex is Len - 1,
    ( NewStateIndex == HighestIndex, append(Tape, [' '], TmpTape);
      TmpTape = Tape
    ),
    nth0(NewStateIndex, TmpTape, Tmp),
    replace(TmpTape, NewStateIndex, State, TmpTape2),
    replace(TmpTape2, StateIndex, Tmp, NewTape).

% Writes speicified symbol on tape at head location
writeSymbol(Tape, State, Symbol, NewTape) :-
    nth0(StateIndex, Tape, State),
    SymbolIndex is StateIndex + 1,
    replace(Tape, SymbolIndex, Symbol, NewTape).

% Changes state on tape
changeState(Tape, OldState, NewState, NewTape) :-
    nth0(StateIndex, Tape, OldState), replace(Tape, StateIndex, NewState, NewTape).

% Replaces element in list at specified index
replace([_|RestElements], 0, NewElement, [NewElement|RestElements]).
replace([FirstElement|RestOriginalElements], Index, NewElement, [FirstElement|RestElements]):-
    Index > -1,
    NewIndex is Index - 1,
    replace(RestOriginalElements, NewIndex, NewElement, RestElements), !.
replace(List, _, _, List).

% Writes configurations after simmulation
writeConfigurations([]).
writeConfigurations([Configuration|RestConfigurations]) :-
    Configuration == [] ;
    writef("%s\n", [Configuration]), writeConfigurations(RestConfigurations).

% vim: expandtab:shiftwidth=4:tabstop=4:softtabstop=0:textwidth=120
