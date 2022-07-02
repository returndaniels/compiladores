all: mini_js entrada.txt
	./mini_js < entrada.txt > saida.txt

gerador_fi: lex.yy.c y.tab.c
	g++ -std=c++17 -o mini_js y.tab.c -lfl	
	
lex.yy.c: mini_js.l
	lex mini_js.l
	
y.tab.c: mini_js.y lex.yy.c
	yacc mini_js.y
	
clean: 
	rm -f lex.yy.c y.tab.c mini_js