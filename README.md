# Turing Machine

Naive implementation of Turing Machine (https://en.wikipedia.org/wiki/Turing_machine). It read input from stdin.

Transition search is implemented using IDS (Iterative Deepening Search).

Turing Machine will:

1. Halt normally and print out each configuration from the initial state to a final state.

2. Halt abnormally if there is no valid trasition for the current state. In that case the program prints out "Abnormal halt!".

3. Cycle forever which ends with end of memory error.

## Input format
All lines except the last one defines transitions of the Turing Machine in the format:

`q1 symbol q2 operator`

q1, q2 - states of the Turing Machine. S is reserved for the initial state. F is reservered for the final state. Other states can be named with `[_a-Z0-9]+`.

symbol - space is reservered for blank symbol.

operator - L is reservered for *move one square on the tape left* operation. R is reservered for *move one square on the the right* operation.

Last line defines initial state of the tape.

## How to start

Compile:

    gmake

Clean:

    gmake clean
