L           [A-Za-z_]
INT         [0-9]
FLOAT       {INT}+("."{INT}+)?([Ee]("+"|"-")?{INT}+)?
LET         "let"
CONST       "const"
VAR         "var"
FOR         "for"
WHILE       "while"
IF          "if"
ELSE        "else"
MAIG        ">="
MEIG        "<="
IG          "=="
DIF         "!="
INC         "+="
INC_ONE     "++"

COMENTARIO  ([/][/].*)|([/][*]([^*]|\*+[^*/])*[*][/])
STRING      (["]([^"]|[\\]["]|["]["])*["])|([']([^']|[\\][']|[']['])*['])
STRING2     [`](.|[\n])*[`]

ID          [$]?{L}*({L}|{INT})*
WS          [ \t\n]


%%
"\n"    { linha++; }
{WS}	  { /* ignora espaços, tabs e '\n' */ } 
{INT}   { yylval.v = yytext; return tk_int; }
{FLOAT} { yylval.v = yytext; return tk_cte_float; }
{LET}   { yylval.v = yytext; return tk_let; }
{CONST} { yylval.v = yytext; return tk_const; }
{VAR}   { yylval.v = yytext; return tk_var; }
{FOR}   { yylval.v = yytext; return tk_for; }
{WHILE}   { yylval.v = yytext; return tk_while; }
{IF}    { yylval.v = yytext; return tk_if; }
{ELSE}    { yylval.v = yytext; return tk_else; }
{MAIG}  { yylval.v = yytext; return tk_maig; }
{MEIG}  { yylval.v = yytext; return tk_meig; }
{IG}    { yylval.v = yytext; return tk_ig; }
{DIF}   { yylval.v = yytext; return tk_diff; }
{INC}   { yylval.v = yytext; return tk_inc; }
{INC_ONE}   { yylval.v = yytext; return tk_inc_one; }

{COMENTARIO}    { yylval.v = yytext; return tk_cmmt; }
{STRING}        { yylval.v = yytext; return tk_str; }
{STRING2}       { yylval.v = yytext; return tk_str2; }

{ID}    { yylval.v = yytext; return tk_id; }
.       { yylval.v = yytext; return *yytext; }

%%
