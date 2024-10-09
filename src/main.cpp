#include <cassert>
#include <cstdio>
#include <iostream>
#include <memory>
#include <string>

#include "ast.hpp"

using namespace std;

extern FILE *yyin;
extern int yyparse(unique_ptr<BaseAST> &ast);

int main(int argc, const char *argv[]) {

	// compiler mode inFile -o outFile
	assert(argc == 5);
	auto mode = argv[1];
	auto input = argv[2];
	auto output = argv[4];

	// 打开输入文件，并且指定 lexer 在解析的时候读取这个文件
	yyin = fopen(input, "r");
	assert(yyin);

	// 调用 parser 函数，parser 函数会进一步调用 lexer 解析输入文件
	unique_ptr<BaseAST> ast;
	auto ret = yyparse(ast);
	assert(!ret);

	// 输出解析得到的 ast，其实就是个字符串
	ast->Dump();
	return 0;
}