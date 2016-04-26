# Project: Turing Machine
# Course: Funcional and Logic Programming
# Author: Tomas Bruckner, xbruck02@stud.fit.vutbr.cz
# Date: 2016-04-26

all:
	swipl -q -g main -o flp16-log -c flp16-log.pl

clean:
	rm flp16-log.pl

