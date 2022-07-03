%{
#include <string>
#include <vector>
#include <sstream>
#include <iostream>
#include <map>

using namespace std;

struct Atributos {
  string v;
};

struct Label {
  string n;
  int i;
};

#define YYSTYPE Atributos

void erro( string msg );
void concat_str( string st );

int yylex();
void yyerror( const char* );
void label(string v);
void end_label(string v);

int linha = 1;
int labels = 0;
int prev_l = 0;
string str_buffer = "";
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
          label("then"); concat_str("\n?\n"); label("else"); concat_str("\n#\n"); end_label("then");
        } C { end_label("else"); }
  | D
  ;

D : tk_let d
  | A
  ;

d : l ',' d
  | l

l : tk_id { concat_str( $1.v + "\n&\n" + $1.v + "\n"  ); } '=' E { concat_str( "=\n^\n" ); }
  | tk_id { concat_str( $1.v + "\n&\n" ); }
  ;

A : tk_id { concat_str( $1.v + "\n" ); } a
  | tk_id { concat_str( $1.v + "\n" ); } tk_inc { concat_str( $1.v + "\n@\n" ); } E { concat_str( "+\n=\n^\n" ); }
  ;

a : '=' E { concat_str( "=\n^\n" ); }
  | '=' tk_id { concat_str( $2.v + "\n"); } '=' E { concat_str( "=\n^\n" + $2.v + "\n@\n=\n^\n" ); }
  ;
  
E : E '+' E { concat_str( "+\n" ); }
  | E '-' E { concat_str( "-\n" ); }
  | E '*' E { concat_str( "*\n" ); }
  | E '/' E { concat_str( "/\n" ); }
  | E '<' E { concat_str( "<\n" ); }
  | E '>' E { concat_str( ">\n" ); }
  | E tk_ig E   { concat_str( "==\n" ); }
  | E tk_maig E   { concat_str( ">=\n" ); }
  | E tk_meig E   { concat_str( "<=\n" ); }
  | E tk_diff E   { concat_str( "!=\n" ); }
  | F
  ;
  
F : tk_id { concat_str( $1.v + "\n@\n" ); }
  | tk_int { concat_str(  $1.v + "\n" ); }
  | tk_cte_float { concat_str(  $1.v + "\n" ); }
  | tk_str { concat_str(  $1.v + "\n" ); }
  | tk_str2 { concat_str(  $1.v + "\n" ); }
  | tk_cmmt { concat_str(  $1.v + "\n" ); }
  | '(' E ')'
  | tk_id '(' PARAM ')' { concat_str( $1.v + "\n$\n" ); }
  | '{' '}' { concat_str( "{}\n" ); }
  | '[' ']' { concat_str( "[]\n" ); }
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
  str_buffer += '%' + v + '_' + to_string(++labels); 
}

void end_label(string v){
  str_buffer += ':' + v + '_' + to_string(++prev_l) + "\n"; 
}

void concat_str( string st ) {
  str_buffer += st;
}

vector<string> split(string strToSplit, char delimeter)
{
  stringstream ss(strToSplit);
  string item;
  vector<string> splittedStrings;
  while (getline(ss, item, delimeter))
  {
    splittedStrings.push_back(item);
  }
  return splittedStrings;
}

vector<string> replace_labels() {
  vector<string> buffer = split(str_buffer, '\n');
  vector<string> out;
  map<string, Label> mlabel;

  for(int i = 0; i < buffer.size(); i++) {
    if( buffer[i][0] == '%' ) {
      mlabel[buffer[i].substr(1)].n = buffer[i].substr(1);
      mlabel[buffer[i].substr(1)].i = i;
    }  
    out.push_back(buffer[i]);
  }
  
  for( int i = 0; i < out.size(); i++ ) {
    string ss;

    if(out[i][0] != ':') continue;

    ss = out[i].substr(1);
    if(mlabel.count(ss) > 0 ) {
      out[i] = to_string(i+1);
      out[mlabel[ss].i] = to_string(i+1);
    }
  }
  return out;
}

void print_vector(vector<string> v) {
  for( int i = 0; i < v.size(); i++ )
    cout << v[i] << endl;
}

int main() {
  yyparse();
  vector<string> v = replace_labels();
  print_vector(v);
  cout << '.' << endl;
   
  return 0;
}