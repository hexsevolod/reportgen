all: 
	./reportgen.pl direct.txt
parser:
	./parser.pl -i direct.txt 
apply:
	./parser.pl -i direct.txt | ./apply_pattern.pl 
