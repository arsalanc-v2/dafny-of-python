%{
  open Ast
%}

%token EOF INDENT DEDENT NEWLINE LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK COLON SEMICOLON COMMA
%token EQEQ EQ UMINUS NEQ LEQ LT GEQ GT PLUS PLUSEQ MINUS MINUSEQ TIMES TIMESEQ DIVIDE DIVIDEEQ MOD
%token <int> SPACE
%token DEF IF ELSE FOR WHILE BREAK CONTINUE RETURN IN PRINT
%token AND OR NOT TRUE FALSE NONE
%token <string> ATOM INT
%token <int> DEDENTS

%right EQ PLUSEQ MINUSEQ DIVIDEEQ TIMESEQ
%left PLUS MINUS
%left TIMES DIVIDE
%left EQEQ NEQ
%left LT LEQ GT GEQ
%left OR
%left AND
%right NOT UMINUS
%left SEMICOLON

%nonassoc ELSE
%nonassoc LPAREN LBRACK LBRACE
%nonassoc RPAREN RBRACK RBRACE

%start <sexp> f

%%

f:
  | sl=stmts; EOF { Program sl }
  ;

stmts:
  | sl=list(stmt) { sl }
  ;

stmt:
  | s=stmt; NEWLINE { s }
  | s=stmt; SEMICOLON { s }
  | e=exp { Exp e }
  | DEF; a=ATOM; LPAREN; fl=atoms_lst; RPAREN; COLON; sl=suite { Function (Identifier a, fl, sl) }
  | IF; e=exp; COLON; s1=suite; ELSE; COLON; s2=suite { IfElse (e, s1, s2) }
  | IF; e=exp; COLON; s=suite; { IfElse (e, s, []) }
  | RETURN; e=exp { Return e }
  | WHILE; e=exp COLON; s=suite; { While (e, s) }
  | CONTINUE { Continue }
  | BREAK { Break }
  | PRINT; LPAREN; e=exp RPAREN { Print e }
  | a=ATOM; PLUSEQ; e2=exp { Assign ([a], [BinaryOp (Atom a, Plus, e2)]) }
  | a=ATOM; MINUSEQ; e2=exp { Assign ([a], [BinaryOp (Atom a, Minus, e2)]) }
  | a=ATOM; TIMESEQ; e2=exp { Assign ([a], [BinaryOp (Atom a, Times, e2)]) }
  | a=ATOM; DIVIDEEQ; e2=exp { Assign ([a], [BinaryOp (Atom a, Divide, e2)]) }
  ;

exp:
  | e1=exp; PLUS; e2=exp { BinaryOp (e1, Plus, e2) }
  | e1=exp; MINUS; e2=exp { BinaryOp (e1, Minus, e2) }
  | e1=exp; TIMES; e2=exp { BinaryOp (e1, Times, e2) }
  | e1=exp; DIVIDE; e2=exp { BinaryOp (e1, Divide, e2) }
  | e1=exp; MOD; e2=exp { BinaryOp (e1, Mod, e2) }
  | e1=exp; EQEQ; e2=exp { BinaryOp (e1, EqEq, e2) }
  | e1=exp; NEQ; e2=exp { BinaryOp (e1, NEq, e2) }
  | e1=exp; LT; e2=exp { BinaryOp (e1, Lt, e2) }
  | e1=exp; LEQ; e2=exp { BinaryOp (e1, LEq, e2) }
  | e1=exp; GT; e2=exp { BinaryOp (e1, Gt, e2) }
  | e1=exp; GEQ; e2=exp { BinaryOp (e1, GEq, e2) }
  | e1=exp; AND; e2=exp { BinaryOp (e1, And, e2) }
  | e1=exp; OR; e2=exp { BinaryOp (e1, Or, e2) }
  | LPAREN; e=exp; RPAREN; { e }
  | MINUS; e=exp %prec UMINUS { UnaryOp (UMinus, e) }
  | NOT; e=exp %prec NOT { UnaryOp (Not, e) }
  | TRUE { Literal (BooleanLiteral true) }
  | FALSE { Literal (BooleanLiteral false) }
  | i=INT { Literal (IntegerLiteral (int_of_string i))  }
  | a=ATOM { Atom a }
  | e=exp; LPAREN; el=exp_lst; RPAREN { Call (e, el) }
  ;

suite:
  | NEWLINE; INDENT; sl=stmts; DEDENT { sl }
  ;

atoms_lst:
  | { [] }
  | ar=atoms_rest; { ar }
  ;

atoms_rest:
  | a=ATOM { [a] }
  | ar=atoms_rest; COMMA; a=ATOM { ar@[a] }
  ;

exp_lst:
  | { [] }
  | er=exp_rest { er }
  ;

exp_rest:
  | e=exp { [e] }
  | er=exp_rest; COMMA; e=exp { er@[e] }
  ;

%%
