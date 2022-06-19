%{
#include <iostream>
#include <map>
#include <algorithm>
#include <string>
  
using namespace std; 

int token;
void translate();
void A();
void is_func();
void is_print();
void is_expression();
void is_int_float_p();
void is_fun_const_e();
void is_fat();
void is_pow();
void is_params();
void is_params_separator();
void expression_line();
void T();
void T_line();
void U();
void V();
void W();
void casa( int );

enum TOKEN { tk_id = 256, tk_for, tk_if, tk_int, tk_cte_float, tk_maig, tk_meig, 
        tk_ig, tk_diff, tk_str, tk_str2, tk_cmmt, tk_id_print, tk_id_func };
%}


/* Coloque aqui definições regulares */

L           [A-Za-z_]
INT         [0-9]
FLOAT       {INT}+("."{INT}+)?([Ee]("+"|"-")?{INT}+)?
FOR         [fF][oO][rR]
IF          [iI][fF]
MAIG        ">="
MEIG        "<="
IG          "=="
DIF         "!="

COMENTARIO  ([/][/].*)|([/][*]([^*]|\*+[^*/])*[*][/])
STRING      (["]([^"]|[\\]["]|["]["])*["])|([']([^']|[\\][']|[']['])*['])
STRING2     [`](.|[\n])*[`]

ID          [$]?{L}*({L}|{INT})*
WS          [ \t\n]


ID_PRINT    "print"
ID_FUNCAO   {L}+({L}|{INT})*\(

%%
    /* Padrões e ações. Nesta seção, comentários devem ter um tab antes */

{WS}	{ /* ignora espaços, tabs e '\n' */ } 
{INT}   { return tk_int; }
{FLOAT} { return tk_cte_float; }
{FOR}   { return tk_for; }
{IF}    { return tk_if; }
{MAIG}  { return tk_maig; }
{MEIG}  { return tk_meig; }
{IG}    { return tk_ig; }
{DIF}   { return tk_diff; }

{COMENTARIO}    { return tk_cmmt; }
{STRING}        { return tk_str; }
{STRING2}       { return tk_str2; }

{ID_PRINT} { return tk_id_print; }
{ID_FUNCAO} { return tk_id_func; }
{ID}    { return tk_id; }
.       { return *yytext; }

%%

auto p = (void *) (&yyunput);

void erro(string error_message) {
  cout << "\n*** Error: ***" << endl << error_message << "\n";
  exit( 1 );
}

void print(string str) {
  cout << str << " ";
}

int next_token() {
  return yylex();
}

void translate() {
  while (token != 0) A();
}

void A() {
  switch (token) {
    case tk_id_func: is_func(); casa(';'); break;
    case tk_id_print: is_print(); casa(';'); break;

    case tk_id:
    {
      string lex = yytext;
      casa(tk_id);
      print(lex);
      casa ('=');
      is_expression();
      print("=");
      casa(';');
    }
    break;
  }
}

void is_expression() {
  T();
  expression_line();
}

void T() {
  U();
  T_line();
}

void T_line() {
  switch (token) {
    case '*':
      casa('*');
      U();
      print("*");
      T_line();
      break;
    case '/':
      casa('/');
      U();
      print("/");
      T_line();
      break;
  }
}

void U() {
  switch (token){
    case '+': casa('+'); V(); break;
    case '-': print("0"); casa('-'); V(); print("-"); break;
    default: W(); is_pow();
  }
}

void V() {
  switch (token) {
    case tk_id_func:
    case tk_id:
    case tk_int:
    case tk_cte_float:
    case tk_cmmt:
    case tk_str:
    case tk_str2:
    case '(':
    case '+':
    case '-':
      U();
      break;
  }
}

void W() {
  is_fun_const_e();
  is_fat();  
}

void is_int_float_p() {
  string lex = yytext;
  switch (token) {
    case tk_id: casa(tk_id); print(lex + " @"); break;
    case tk_int: casa(tk_int); print(lex); break;
    case tk_cte_float: casa(tk_cte_float); print(lex); break;
    case tk_cmmt: casa(tk_cmmt); print(lex); break;
    case tk_str: casa(tk_str); print(lex); break;
    case tk_str2: casa(tk_str2); print(lex); break;
    case '(': casa('('); is_expression(); casa(')'); break;

    default: {   
      string e = yytext;
      erro("É esperado um token de valor inteiro, flutuante ou (. Mas foi encontrado " + e);
    }
  }
}

void is_fun_const_e() {
  switch (token){
    case tk_id_func:  is_func(); break;
    case tk_id:
    case tk_int:
    case tk_cte_float:
    case tk_cmmt:
    case tk_str:
    case tk_str2:
    case '(': is_int_float_p(); break;

    default: {
      string e = yytext;
      erro("É esperado um token de chamada de função, constante ou expressão. Mas foi encontrado " + e);
    }
  }  
}

void is_print(){
  if (token == tk_id_print){
    casa(tk_id_print);
    is_expression();
    print("print #");
  }

  else {   
    string e = yytext;
    erro("É esperado um token de identificador, comando print ou chamada de função. Mas foi encontrado " + e);
  }
}

void is_func() {
  string lex = yytext;
  casa (tk_id_func);    
  lex.erase(remove(lex.begin(), lex.end(), '('), lex.end());    
  is_params();
  casa(')');
  print(lex + " #");
}

void is_params() {
  if (token != ')') {
    is_expression();
    is_params_separator();
  }
}

void is_params_separator() {
  if (token == ',') {
      casa(',');
      is_expression();
      is_params_separator();
  }
}

void expression_line() {
  switch (token) {
    case '+':
      casa('+');
      T();
      print("+");
      expression_line();
      break;
    case '-':
      casa('-');
      T();
      print("-");
      expression_line();
      break;
  }
}

void is_pow() {
  if (token == '^') {
    casa('^');
    W();
    is_pow();
    print("^");
  }
}

void is_fat() {
  if (token == '!'){
    casa('!');
    print("fat #");
    is_fat();        
  }
}

void casa( int esperado ) {
  if(token == esperado){
    token = next_token();
  } else {
    printf("\nÉ esperado o token '%c', mas foi encontrado '%c'", esperado, token);
    exit(1);
  }
}

int main() {
  token = next_token();
  translate();
  return 0;
}


