%{
#include <string>
#include <iostream>
#include <map>

using namespace std;

struct Atributos {
  string v;
};

#define YYSTYPE Atributos

void erro( string msg );
void Print( string st );

int yylex();
void yyerror( const char* );
void label(string v);
void end_label(string v);

int linha = 1;
int labels = 0;
int prev_l = 0;
%}

%token tk_id tk_int tk_cte_float tk_maig tk_meig tk_ig tk_diff tk_inc tk_inc_one tk_str tk_str2 tk_cmmt 
%token tk_if tk_else tk_for tk_while tk_id_print tk_let tk_const tk_var

%nonassoc '<' '>' tk_maig tk_meig tk_ig tk_diff
%left '+' '-'
%left '*' '/'

%%

P : C ';' P
  | C ';'
  | '{' P '}'
  ;

C : tk_if '(' E ')' { 
          label(":then_"); Print(" ? "); label(":else_"); Print("\n# "); end_label(":then_");
        } C { end_label(":else_"); }
  | D
  ;

D : tk_let d
  | A
  ;

d : l ',' d
  | l

l : tk_id { Print( $1.v + "& " + $1.v + " "  ); } '=' E { Print( "= ^\n" ); }
  | tk_id { Print( $1.v + "& " ); }
  ;

A : tk_id { Print( $1.v + " " ); } a
  | tk_id { Print( $1.v + " " ); } tk_inc { Print( $1.v + "@ " ); } E { Print( "+ = ^\n" ); }
  ;

a : '=' E { Print( "= ^\n" ); }
  | '=' tk_id { Print( $2.v + " "); } '=' E { Print( " = ^ " + $2.v + "@  = ^\n" ); }
  ;
  
E : E '+' E { Print( "+ " ); }
  | E '-' E { Print( "- " ); }
  | E '*' E { Print( "* " ); }
  | E '/' E { Print( "/ " ); }
  | E '<' E { Print( "< " ); }
  | E '>' E { Print( "> " ); }
  | E tk_ig E   { Print( "== " ); }
  | E tk_maig E   { Print( ">= " ); }
  | E tk_meig E   { Print( "<= " ); }
  | E tk_diff E   { Print( "!= " ); }
  | F
  ;
  
F : tk_id { Print( $1.v + "@ " ); }
  | tk_int { Print(  $1.v + " " ); }
  | tk_cte_float { Print(  $1.v + " " ); }
  | tk_str { Print(  $1.v + " " ); }
  | tk_str2 { Print(  $1.v + " " ); }
  | tk_cmmt { Print(  $1.v + " " ); }
  | '(' E ')'
  | tk_id '(' PARAM ')' { Print( $1.v + "$ " ); }
  | '{' '}' { Print( "{} " ); }
  | '[' ']' { Print( "[] " ); }
  ;
  
PARAM : ARGs
      |
      ;
  
ARGs : E ',' ARGs
     | E
     ;
  
%%

#include "lex.yy.c"

void yyerror( const char* msg ) {
  cout << endl << "Erro na linha " << linha << ": " 
       << msg << endl << "Perto de : '" << yylval.v << "'" << endl; 

  exit( 0 );
}

void label(string v) {
  cout << v << ++labels; 
}

void end_label(string v){
  cout << endl << v << ++prev_l << ":" << endl; 
}

void Print( string st ) {
  cout << st;
}

int main() {
  yyparse();
  
  cout << '.' << endl;
   
  return 0;
}