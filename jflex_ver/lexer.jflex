//----------------------------------------
// Filename:  lexer.jflex
// To compile: jflex lexer.jflex  
//----------------------------------------
import java.io.*;
%%
%class Lexer
%unicode
%line
%column
%type String

%{

%}

/* macros */

letter = [A-Za-z]
digit = [0-9]

%%

/* rules */
{letter}({letter}|{digit})*         { return yytext(); }  //Identifiers
{digit}+                            { return yytext(); }  //Numbers
.		                            { }
[\n\r]                              { }

<<EOF>>                             { return null; }
