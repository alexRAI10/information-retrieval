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
<YYINITIAL> {ANY}              { /* skip one char */ }

/* keeping href URLs: only keep absolute http/https; skip others */

<TAG> "href" {WS}* "=" {WS}* "\""   { yybegin(HREF_DQ); }
<TAG> "href" {WS}* "=" {WS}* "'"    { yybegin(HREF_SQ); }
<TAG> "href" {WS}* "=" {WS}*        { yybegin(HREF_UQ); }

/* double-quoted value */
<HREF_DQ> {SCHEME} [^\"]+             { return yytext().replace("&amp;","&"); }
<HREF_DQ> [^\"]+                      { /* skip non-http(s) */ }
<HREF_DQ> "\""                       { yybegin(TAG); }
<HREF_DQ> <<EOF>>                    { yybegin(YYINITIAL); return null; }   // prevent jam at EOF
<HREF_DQ> {ANY}                      {  }

/* single-quoted */
<HREF_SQ> {SCHEME} [^']+             { return yytext().replace("&amp;","&"); }
<HREF_SQ> [^']+                      {  }
<HREF_SQ> "'"                        { yybegin(TAG); }
<HREF_SQ> <<EOF>>                    { yybegin(YYINITIAL); return null; }
<HREF_SQ> {ANY}                      {  }

/* unquoted (ends on ws or '>') */
<HREF_UQ> {SCHEME} [^ \t\f\r\n\"'>]+ { return yytext().replace("&amp;","&"); }
<HREF_UQ> [^ \t\f\r\n\"'>]+          {  }
<HREF_UQ> [ \t\f\r\n>]+              { yybegin(TAG); }
<HREF_UQ> <<EOF>>                    { yybegin(YYINITIAL); return null; }
<HREF_UQ> {ANY}                      {  }

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
