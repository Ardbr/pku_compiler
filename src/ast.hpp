#pragma once

#include <memory>
#include <string>
#include <iostream>


// 所有 AST 的基类
class BaseAST {
public:
    virtual ~BaseAST() = default;

    virtual void Dump() const = 0;
};


// CompUnit 是 BaseAST
class CompUnitAST : public BaseAST {
public:
    void Dump() const override {
        std::cout << "CompUnitAST { ";
        func_def->Dump();
        std::cout << " }";
    }


public:
    // 用智能指针管理对象
    std::unique_ptr<BaseAST> func_def;

};


// FuncDef 也是 BaseAST
class FuncDefAST : public BaseAST {
public:
    void Dump() const override {
        std::cout << "FuncDefAST { ";
        func_type->Dump();
        std::cout << ", " << ident << ", ";
        block->Dump();
        std::cout << " }";
    }

public:
    std::unique_ptr<BaseAST> func_type;
    std::string ident;
    std::unique_ptr<BaseAST> block;
};


// FuncType 也是 BaseAST
class FuncTypeAST : public BaseAST {
public:
    void Dump() const override {
        std::cout << "FuncTypeAST { ";
        std::cout << type;
        std::cout << " }";
    }

public:
    std::string type;
};


// Block 也是 BaseAST
class BlockAST : public BaseAST {
public:
    void Dump() const override {
        std::cout << "BlockAST { ";
        stmt->Dump();
        std::cout << " }";
    }

public:
    std::unique_ptr<BaseAST> stmt;
};


// StmtAST 也是 BaseAST
class StmtAST : public BaseAST {
public:
    void Dump() const override {
        std::cout << "StmtAST { ";
        std::cout << number;
        std::cout << " }";
    }

public:
    int number;
};

