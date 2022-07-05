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
void create_if_label(string);
void end_if_label(string);
void create_while_label(string);
void end_while_label(string);
void concat_str(string);
vector<string> replace_labels();
vector<string> split(string, char);
void print_vector(vector<string>);

int linha = 1;

map<string, Label> mlabel;
int if_labels = 0;
int prev_if_lalbels = 0;
int while_labels = 0;
int prev_while_lalbels = 0;
string while_start_p = "";
int while_start_i = 0;

string str_buffer = "";
%}

%token tk_id tk_int tk_cte_float tk_maig tk_meig tk_ig tk_diff tk_inc tk_inc_one tk_str tk_str2 tk_cmmt 
%token tk_if tk_else tk_for tk_while tk_id_print tk_let tk_const tk_var

%right tk_inc_one
%nonassoc '<' '>' tk_maig tk_meig tk_ig tk_diff
%left '+' '-'
%left '*' '/'

%%

P : C P
  | C
  ;

C : tk_if '(' E ')' { 
    create_if_label("then"); 
    concat_str("?\n"); 
    create_if_label("end_if"); 
    concat_str("#\n"); 
    end_if_label("then");
  } C { end_if_label("end_if"); }
  | tk_while { 
    concat_str(while_start_p = ":while_"+to_string(while_labels));
    concat_str("\n");
    while_start_i = while_labels++;
   } '(' E ')' { 
    create_while_label("then"); 
    concat_str("?\n"); 
    create_while_label("end_while"); 
    concat_str("#\n"); 
    end_while_label("then");
  } C {
    concat_str("%while_" + to_string(while_start_i) + "\n"); 
    concat_str("#\n");
    end_while_label("end_while"); 
  }
  | '{' C '}'
  | D ';'
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
  | '-' { concat_str("0\n"); } E { concat_str("-\n"); }
  | F
  ;
  
F : tk_id { concat_str( $1.v + "\n@\n" ); }
  | tk_int { concat_str(  $1.v + "\n" ); }
  | tk_cte_float { concat_str(  $1.v + "\n" ); }
  | tk_str { concat_str(  $1.v + "\n" ); }
  | tk_str2 { concat_str(  $1.v + "\n" ); }
  | tk_cmmt { concat_str(  $1.v + "\n" ); }
  | '(' E ')'
  | tk_id tk_inc_one  { concat_str( $1.v  + '\n' + $1.v + "\n@\n1\n+\n=\n" ); }
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
  cout << str_buffer;
  cout << endl << msg << " linha " << linha << endl 
       << "Perto de\n '" << yylval.v << "'." << endl; 

  exit( 0 );
}

void create_if_label(string v) {
  str_buffer += '%' + v + '_' + to_string(++if_labels) + '\n'; 
}

void end_if_label(string v){
  str_buffer += ':' + v + '_' + to_string(++prev_if_lalbels) + "\n"; 
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