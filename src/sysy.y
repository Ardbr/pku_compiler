/* 这一部分是添加在 Bison 的头文件中 */
%code requires {
    // 为了在 parser 中使用 unique_ptr
    #include <memory>

    // 为了在 parser 中使用 string
    #include <string>

    // 为了在 yylval 内使用 AST
    #include "ast.hpp"
}


/* 这一部分是添加在 Bison 的源文件中 */
%{

#include <iostream>
#include <memory>
#include <string>
#include "ast.hpp"

// 声明 lexer 函数和错误处理函数
// 首先写自行附加的参数 (std::unique_ptr<BaseAST> &ast)，然后再写内部默认的参数 (const char *s)

int yylex();
void yyerror(std::unique_ptr<BaseAST> &ast, const char *s);

using namespace std;

%}

// 定义 parser 函数的附加参数
%parse-param { std::unique_ptr<BaseAST> &ast }

// yylval 是一个全局变量，用于返回当前 token 的值，就是用 %union 来说明。
%union {
    std::string *str_val;
    int int_val;
    BaseAST *ast_val;
}

// lexer 返回的所有的 token 种类的声明，其中 IDENT 和 INT_CONST 是有 token 值的
%token INT RETURN
%token <str_val> IDENT
%token <int_val> INT_CONST  

// 非终结符的类型定义
%type <ast_val> FuncDef FuncType Block Stmt
%type <int_val> Number


%%
// 开始符 CompUnit :: FuncDef，大括号里面说明了解析完成后 parser 要做的事情。
// FuncDef 会返回一个 str_val，也就是字符串指针
// 而 parser 一旦解析完 CompUnit，就说明所有的 token 都被解析完了，即解析结束了
// 此时应该把 FuncDef 返回的结果收集起来，作为 AST 传给调用 parser 的函数
// $1 指代规则里第一个符号的返回值，也就是 FuncDef 的返回值

CompUnit : FuncDef {
    // ast = unique_ptr<string>($1);
    auto comp_unit = make_unique<CompUnitAST>();
    comp_unit->func_def = unique_ptr<BaseAST>($1);
    ast = move(comp_unit);
};

// 处理总体的函数，例如对于 "int main() { return 0; }"，则有如下分割
// FuncDef  ->  "int"
// IDENT    ->  "main"
// '(' ')'  ->  "()"
// Block    ->  "{ return 0; }"
// Stmt     ->  "return 0s;"
// Number   ->  "0"

FuncDef : FuncType IDENT '(' ')' Block {
    // auto type = unique_ptr<string>($1);
    // auto ident = unique_ptr<string>($2);
    // auto block = unique_ptr<string>($5);
    // $$ = new string(*type + " " + *ident + "() " + *block);

    auto ast = new FuncDefAST();
    ast->func_type = unique_ptr<BaseAST>($1);
    ast->ident = *unique_ptr<string>($2);
    ast->block = unique_ptr<BaseAST>($5);
    $$ = ast;
};

FuncType : INT {
    // $$ = new string("int");

    auto ast = new FuncTypeAST();
    ast->type = *make_unique<string>("int");
    $$ = ast;
};

Block : '{' Stmt '}' {
    // auto stmt = unique_ptr<string>($2);
    // $$ = new string("{ " + *stmt + " }");
    
    auto ast = new BlockAST();
    ast->stmt = unique_ptr<BaseAST>($2);
    $$ = ast;
};

Stmt : RETURN Number ';' {
    // auto number = unique_ptr<string>($2);
    // $$ = new string("return " + *number + ";");

    auto ast = new StmtAST();
    ast->number = *make_unique<int>($2);
    $$ = ast;
};

Number : INT_CONST {
    $$ = $1;
};

%%


// 定义错误处理函数，其中第二个参数是错误信息
// parser 如果发生错误（例如输入的程序出现了语法错误），就会调用这个函数

void yyerror(unique_ptr<BaseAST> &ast, const char *s) {
    cerr << "error: " << s << endl;
}

