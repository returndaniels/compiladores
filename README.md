## Compiladores I - IC/UFRJ

# Run lex code
```bash
lex scan.lex
g++ -Wall -std=c++17 main.cc -ll  
```

# Run yacc code
```bash
lex scan.l
yacc scan.y
g++ -Wall -std=c++17 y.tab.c -ll  
```