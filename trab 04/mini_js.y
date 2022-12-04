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
void not_declared_error( string var );
void sign( string var );
void create_if_label(string);
void end_if_label(string);
void create_while_label(string);
void end_while_label(string);
void concat_str(string);
vector<string> replace_labels();
vector<string> split(string, char);
void print_vector(vector<string>);
void concat_if();
void concat_else();

int linha = 1;

map<string, int> vars;
map<string, Label> mlabel;
map<string, int> clabel;
int if_labels = 0;
int prev_if_lalbels = 0;
int while_labels = 0;
int prev_while_lalbels = 0;
string while_start_p = "";
int while_start_i = 0;

string str_buffer = "";
%}

%token tk_id tk_int tk_cte_float tk_maig tk_meig tk_ig tk_diff tk_inc tk_inc_one tk_str tk_str2 tk_cmmt 
%token tk_if tk_else tk_for tk_while tk_id_print tk_let tk_const tk_var tk_func

%nonassoc '<' '>' tk_maig tk_meig tk_ig tk_diff
%left '+' '-'
%left '*' '/'
%right tk_inc_one
%left '[' 
%left '.'

%%

P : CMD
  ;

CMD : C CMD
    | C

C : IF 
  | W
  | D ';'
  ;

BLOCO : '{' CMD '}' ';'
      | '{' CMD '}' 
      | C
      ;

I : tk_if '(' E ')' { concat_if(); }
  ;
  
IF : I BLOCO { concat_else(); } tk_else BLOCO { end_if_label("end_else"); }
   | I BLOCO { concat_else(); end_if_label("end_else"); }
   ;

W : tk_while { 
    concat_str(while_start_p = ":while_"+to_string(while_labels));
    concat_str("\n");
    while_start_i = while_labels++;
  } '(' E ')' { 
    create_while_label("then"); 
    concat_str("?\n"); 
    create_while_label("end_while"); 
    concat_str("#\n"); 
    end_while_label("then");
  } BLOCO {
    concat_str("%while_" + to_string(while_start_i) + "\n"); 
    concat_str("#\n");
    end_while_label("end_while"); 
  }
  ;

D : tk_let d
  | A
  | E
  ;

d : l ',' d
  | l

l : LVALUE { concat_str( "&\n" + $1.v  ); sign($1.v); } '=' E { concat_str( "=\n^\n" ); }
  | LVALUE { concat_str( "&\n" ); sign($1.v); }
  ;

A : LVALUE a { not_declared_error($1.v); }
  | LVALUEPROP '=' E { concat_str( "[=]\n^\n" ); }
  | LVALUE tk_inc { concat_str( $1.v + "@\n" ); } E { concat_str( "+\n=\n^\n" ); }
  | LVALUEPROP tk_inc { concat_str( $1.v + "[@]\n" ); } E { concat_str( "+\n[=]\n^\n" ); }
  ;

a : '=' E { concat_str( "=\n^\n" ); }
  | '=' LVALUE '=' E { concat_str( "=\n^\n" + $2.v + "@\n=\n^\n" ); }
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
  | '-' { concat_str("0\n"); } E { concat_str("-\n"); }
  | F
  ;
  
F : LVALUE { concat_str("@\n"); $$.v = $1.v + "@\n"; }
  | LVALUEPROP { concat_str("[@]\n"); $$.v = $1.v + "[@]\n"; }
  | tk_int { concat_str(  $1.v + "\n" ); }
  | tk_cte_float { concat_str(  $1.v + "\n" ); }
  | tk_str { concat_str(  $1.v + "\n" ); }
  | tk_str2 { concat_str(  $1.v + "\n" ); }
  | tk_cmmt { concat_str(  $1.v + "\n" ); }
  | '(' E ')'
  | LVALUE { concat_str("@\n"); } tk_inc_one  { concat_str( $1.v + $1.v + "@\n1\n+\n=\n^\n" ); } 
  | LVALUEPROP { concat_str("[@]\n"); } tk_inc_one  { concat_str( $1.v + $1.v + "[@]\n1\n+\n[=]\n^\n" ); }
  | tk_id '(' PARAM ')' { concat_str( $1.v + "\n$\n" ); }
  | '{' '}' { concat_str( "{}\n" ); }
  | '[' ']' { concat_str( "[]\n" ); }
  | DEF_FUNC
  ;


DEF_FUNC : tk_func LVALUE '(' PARAM ')'
         ;

LVALUE : tk_id { concat_str( $1.v + "\n" ); $$.v = $1.v + "\n"; }
       ;

LVALUEPROP : E '.' tk_id { concat_str( $3.v + "\n" ); $$.v = $1.v + $3.v + "\n"; }
           | E '[' E ']'{ $$.v = $1.v + $3.v + "\n"; }
           ;

PARAM : ARGs
      |
      ;
  
ARGs : E ',' ARGs
     | E
     ;
  
%%

#include "lex.yy.c"

const string WHITESPACE = " \n\r\t\f\v";

string rtrim(const string &s)
{
    size_t end = s.find_last_not_of(WHITESPACE);
    return (end == string::npos) ? "" : s.substr(0, end + 1);
}

void not_declared_error(string s) {
  string var = rtrim(s);
  if(vars.count(var) < 1) {
    cout << "Erro: a variável '"+ var +"' não foi declarada.\n";
    exit(1);
  }
}

void sign(string s) {
  string var = rtrim(s);
  if(vars.count(var) > 0) {
    cout << "Erro: a variável '"+ var +"' já foi declarada na linha " << vars[var] << ".\n";
    exit(1);
  }
  vars[var] = linha;
}

void yyerror( const char* msg ) {
  cout << str_buffer;
  cout << endl << msg << " linha " << linha << endl 
       << "Perto de\n '" << yylval.v << "'." << endl; 

  exit(1);
}

void concat_if() { 
  create_if_label("then");   // pula para escopo do if
  concat_str("?\n");        
  create_if_label("end_if"); // pula o if 
  concat_str("#\n");        
  end_if_label("then");      // inicia escopo do if
  create_if_label("end_else");  // pula escopo do esle (se houver)
}

void concat_else() { 
  concat_str("#\n");
  end_if_label("end_if"); 
}

void create_if_label(string v) {
  str_buffer += '%' + v + '_' + to_string(++clabel[v]) + '\n'; 
}

void end_if_label(string v){
  str_buffer += ':' + v + '_' + to_string(++clabel["_" + v]) + "\n"; 
}

void create_while_label(string v) {
  str_buffer += '%' + v + '_' + to_string(while_labels++) + '\n';
}

void end_while_label(string v){
  str_buffer += ':' + v + '_' + to_string(++prev_while_lalbels) + "\n"; 
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

  for(int i = 0, j = 0; i < buffer.size(); i++) {
    string ss;
    if( buffer[i][0] == '%' ) {
      ss = buffer[i].substr(1);
      if(mlabel.count(ss) == 0 ) {
        mlabel[ss].n = ss;
        mlabel[ss].i = j;
        out.push_back(buffer[i]);
      } else {
        out.push_back(to_string(mlabel[ss].i));
      }
      j++;
    } else if( buffer[i][0] == ':' ) {
      ss = buffer[i].substr(1);
      if(mlabel.count(ss) > 0 )
        out[mlabel[ss].i] = to_string(j);
      else {
        mlabel[ss].i = j;
        //out[mlabel[ss].i] = to_string(j);
      }
    } else {
      out.push_back(buffer[i]);
      j++;
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