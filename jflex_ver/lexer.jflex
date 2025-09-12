//----------------------------------------
// Filename:  lexer.jflex
// To compile: jflex lexer.jflex  
//----------------------------------------
import java.io.*;
import java.util.Locale;
%%
%class Lexer
%unicode
%line
%column
%type String
%ignorecase

/* States */
%x TAG COMMENT SCRIPT STYLE
%x HREF_DQ HREF_SQ HREF_UQ

/* Macros */
LETTER      = [A-Za-z_]
DIGIT       = [0-9]
WS          = [ \t\f\r\n]+
ANY         = [^]
SCHEME      = [Hh][Tt][Tt][Pp][Ss]?"://"

/* email Macros */
MAILTO      = [Mm][Aa][Ii][Ll][Tt][Oo] ":"
LOCAL       = [A-Za-z0-9._%+\-]+
LABEL       = [A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?
DOMAIN      = {LABEL}("."{LABEL})+
EMAIL       = {LOCAL}"@"{DOMAIN}

/* Number Macros */
SIGN        = [+-]?
EXP         = [eE]{SIGN}{DIGIT}+
FRACTION    = {DIGIT}+"."{DIGIT}+
FLOAT       = {SIGN}?(({FRACTION}({EXP})?)|({DIGIT}+{EXP}))
INT         = {SIGN}?{DIGIT}+
%%      

/* Rules */
"<!--"                         { yybegin(COMMENT); }
"<script" [^>]* ">"            { yybegin(SCRIPT); }
"<style"  [^>]* ">"            { yybegin(STYLE); }
"<!doctype" [^>]* ">"          {  }                   /* skip doctype */
"<?" [^>]* ">"                 {  }                   /* skip processing instructions */
"<"                            { yybegin(TAG); }

/* outside markup */

/* email */
{MAILTO}{EMAIL}                { return yytext().substring(7); } /* strip "mailto:" */
{EMAIL}                        { return yytext(); }

/* numbers */
{FLOAT}                        { return yytext(); }   /* keep float numbers */
{INT}                          { return yytext(); }   /* keep integers */

/* words */
{LETTER}({LETTER}|{DIGIT})*    { return yytext().toLowerCase(Locale.ROOT); }   /* identifiers (added toLowerCase to lowcase tokens)*/
{WS}                           {  }                   /* skip whitespace */
"&" [A-Za-z0-9#]+ ";"          {  }                   /* skip HTML entities */
.                              {  }                   /* skip punctuation/other chars */

/* keeping href URLs */

<TAG> "href" {WS}* "=" {WS}* "\""   { yybegin(HREF_DQ); }
<TAG> "href" {WS}* "=" {WS}* "'"    { yybegin(HREF_SQ); }
<TAG> "href" {WS}* "=" {WS}*        { yybegin(HREF_UQ); }

/* double-quoted value */
<HREF_DQ> {SCHEME} [^\"]+            { return yytext().replace("&amp;", "&"); }  
<HREF_DQ> [^\"]+                     { /* skip non-http(s) values (mailto:/relative/etc.) */ }
<HREF_DQ> "\""                      { yybegin(TAG); }

/* single-quoted value */
<HREF_SQ> {SCHEME} [^']+            { return yytext().replace("&amp;", "&"); }
<HREF_SQ> [^']+                     { /* skip */ }
<HREF_SQ> "'"                       { yybegin(TAG); }

/* unquoted value ends on space or '>' */
<HREF_UQ> {SCHEME} [^ \t\f\r\n\"'>]+ { return yytext().replace("&amp;", "&"); }
<HREF_UQ> [^ \t\f\r\n\"'>]+         { /* skip */ }
<HREF_UQ> [ \t\f\r\n>]+             { yybegin(TAG); }

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
