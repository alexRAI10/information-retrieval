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
%ignorecase

/* States */
%x TAG COMMENT SCRIPT STYLE

/* Macros */
LETTER  = [A-Za-z_]
DIGIT   = [0-9]
WS      = [ \t\f\r\n]+
ANY     = [^]

%%

/* Rules */
"<!--"                         { yybegin(COMMENT); }
"<script" [^>]* ">"            { yybegin(SCRIPT); }
"<style"  [^>]* ">"            { yybegin(STYLE); }
"<!doctype" [^>]* ">"          {  }                   /* skip doctype */
"<?" [^>]* ">"                 {  }                   /* skip processing instructions */
"<"                            { yybegin(TAG); }

/* outside markup */
{LETTER}({LETTER}|{DIGIT})*    { return yytext(); }   /* identifiers */
{DIGIT}+                       { return yytext(); }   /* numbers */
{WS}                           {  }                   /* skip whitespace */
"&" [A-Za-z0-9#]+ ";"          {  }                   /* skip HTML entities */
.                              {  }                   /* skip punctuation/other chars */

/* HTML elements */
<TAG> ">"                      { yybegin(YYINITIAL); }
<TAG> {ANY}                    {  }                   /* skip HTML tags*/

<COMMENT> "-->"                { yybegin(YYINITIAL); }
<COMMENT> {ANY}                {  }                   /* skip comments*/

<SCRIPT> "</script" [^>]* ">"  { yybegin(YYINITIAL); }
<SCRIPT> {ANY}                 {  }                   /* skip JS tags*/

<STYLE> "</style"  [^>]* ">"   { yybegin(YYINITIAL); }
<STYLE> {ANY}                  {  }                   /* skip CSS tags*/

<<EOF>>                        { return null; }
