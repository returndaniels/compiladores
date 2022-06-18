
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


%%
    /* Padrões e ações. Nesta seção, comentários devem ter um tab antes */

{WS}	{ /* ignora espaços, tabs e '\n' */ } 
{INT}   { return _INT; }
{FLOAT} { return _FLOAT; }
{FOR}   { return _FOR; }
{IF}    { return _IF; }
{MAIG}  { return _MAIG; }
{MEIG}  { return _MEIG; }
{IG}    { return _IG; }
{DIF}   { return _DIF; }

{COMENTARIO}    { return _COMENTARIO; }
{STRING}        { return _STRING; }
{STRING2}       { return _STRING2; }

{ID}    { return _ID; }
.       { return *yytext; 
          /* Essa deve ser a última regra. Dessa forma qualquer caractere isolado será retornado pelo seu código ascii. */ }

%%

/* Não coloque nada aqui - a função main é automaticamente incluída na hora de avaliar e dar a nota. */