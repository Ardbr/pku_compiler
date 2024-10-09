/*
含义：禁用 yywrap 函数。
作用：当词法分析器到达输入的末尾时，默认情况下会调用 yywrap 函数来处理输入流。
如果不需要处理多重输入流，可以使用这个选项来避免调用 yywrap，从而简化代码。
*/
%option noyywrap


/*
含义：禁止使用 unput 函数。
作用：unput 函数用于将字符放回输入流。这意味着在分析过程中，不允许将字符放回到输入流，
这可以防止某些意外的行为和错误，确保输入流的顺序性。
*/
%option nounput

/*
含义：禁用对输入的读操作。
作用：这个选项表示词法分析器不读取任何输入。这通常用于某些特定场景，
比如你只想使用词法分析器处理已经提供的输入，而不希望它自己去读取文件或标准输入。
*/
%option noinput


/* 包含一些必要的头文件或者全局变量 */
%{

#include <cstdlib>
#include <string>

/* Flex 会用到 Bison 中关于 token 的定义，所以要 include Bison 生成的头文件 */
#include "sysy.tab.hpp"

using namespace std;

%}

/* 对于 Flex，这里定义某个符号对应的正则表达式 */
/* 空白符和注释（只处理了行注释）*/
WhiteSpace  [ \t\n\r]*
LineComment "//".*

/* 标识符 */
Identifier  [a-zA-Z_][a-zA-Z0-9_]*

/* 整数字面量 */
Decimal     [1-9][0-9]*
Octal       0[0-7]*
Hexadecimal 0[xX][0-9a-fA-F]+


%%
    /* 这一部分是 rules 规则部分，定义了遇到每种符号时应该采取什么样的处理 */
    /* 如果是一些空白符，跳过不进行处理 */
{WhiteSpace}    { }
{LineComment}   { }

    /* 遇到关键字时返回对应的 token */
"int"           { return INT; }
"return"        { return RETURN; }

    /* 遇到标识符就把标识符存起来，然后返回对应的 token */
{Identifier}    { yylval.str_val = new string(yytext); return IDENT; }

    /* 遇到整数字面量，先把读到的字符串转成整数，然后存起来，并返回对应的 token */
{Decimal}       { yylval.int_val = strtol(yytext, nullptr, 0); return INT_CONST; }
{Octal}         { yylval.int_val = strtol(yytext, nullptr, 0); return INT_CONST; }
{Hexadecimal}   { yylval.int_val = strtol(yytext, nullptr, 0); return INT_CONST; }

    /* 遇到单个字符，就直接返回单个字符作为 token。取了当前匹配的字符，然后把它转成了整数，交给 Bison 生成的 parse 处理 */
.               { return yytext[0]; }
%%