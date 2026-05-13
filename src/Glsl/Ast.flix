///
/// `Glsl.Ast` — Abstract syntax tree for GLSL declarations, statements, and blocks.
///
/// This module defines the AST types for all GLSL constructs except expressions
/// (which live in Expr.flix). The AST is structured to match the GLSL grammar
/// and support code generation, optimization, and parsing.
///
pub mod Glsl.Ast {

    ///
    /// Layout qualifiers for uniforms, interface blocks, and storage buffers.
    ///
    pub enum LayoutItem with Eq, ToString {
        case Location(Int32)
        case Binding(Int32)
        case Set(Int32)
        case Std140
        case Std430
        case PushConstant
        case RowMajor
        case ColumnMajor
    }

    ///
    /// Type alias for a list of layout qualifiers.
    ///
    pub type alias Layout = Vector[LayoutItem]

    ///
    /// Direction of a varying (in or out).
    ///
    pub enum VaryingDirection with Eq, ToString {
        case In
        case Out
    }

    ///
    /// Qualifier for a function parameter (plain, inout, const).
    ///
    pub enum ParamQualifier with Eq, ToString {
        case Plain
        case Inout
        case Const
    }

    ///
    /// Render a layout qualifier vector as a GLSL layout(...) qualifier string.
    /// Returns empty string if the vector is empty.
    ///
    pub def renderLayout(layout: Layout): String =
        if (Vector.isEmpty(layout))
            ""
        else
            let items = layout |> Vector.map(renderLayoutItem) |> Vector.join(", ");
            "layout(${items}) "

    ///
    /// Render a single layout item.
    ///
    def renderLayoutItem(item: LayoutItem): String = match item {
        case LayoutItem.Location(loc) => "location = ${loc}"
        case LayoutItem.Binding(bind) => "binding = ${bind}"
        case LayoutItem.Set(s) => "set = ${s}"
        case LayoutItem.Std140 => "std140"
        case LayoutItem.Std430 => "std430"
        case LayoutItem.PushConstant => "push_constant"
        case LayoutItem.RowMajor => "row_major"
        case LayoutItem.ColumnMajor => "column_major"
    }

    ///
    /// Preprocessor directives: #define, #extension, #include, #ifndef.
    ///
    pub enum Preprocessor with Eq {
        case Define(String, String)
        case DefineFn(String, Vector[String], String)
        case Ifndef(String, String)
        case Extension(String, String)
        case Include(String)
    }

    ///
    /// Member of a struct or interface block.
    ///
    pub enum BlockMember with Eq {
        case Member(Glsl.Types.TypeRef, String)
        case MemberLineComment(String)
        case MemberBlockComment(String)
    }

    ///
    /// Function parameter with qualifier (plain, inout, const).
    ///
    pub enum FunctionParam with Eq {
        case Param(ParamQualifier, Glsl.Types.TypeRef, String)
    }

    ///
    /// For loop initializer: declaration, expression, or none.
    ///
    pub enum ForInit with Eq {
        case ForInitDecl(Glsl.Types.TypeRef, String, Glsl.Expr.Ast)
        case ForInitExpr(Glsl.Expr.Ast)
        case ForInitNone
    }

    ///
    /// Uniform declaration with type, name, layout, and optional precision.
    ///
    pub enum Uniform with Eq {
        case U(Glsl.Types.TypeRef, String, Layout, Option[Glsl.Types.Precision])
    }

    ///
    /// Vertex attribute declaration.
    ///
    pub enum Attribute with Eq {
        case A(Int32, Glsl.Types.TypeRef, String)
    }

    ///
    /// Varying (in/out) declaration.
    ///
    pub enum Varying with Eq {
        case V(VaryingDirection, Glsl.Types.TypeRef, String)
    }

    ///
    /// Fragment output declaration.
    ///
    pub enum Output with Eq {
        case O(Int32, Glsl.Types.TypeRef, String)
    }

    ///
    /// Global variable declaration (placed before main).
    ///
    pub enum Global with Eq {
        case G(Glsl.Types.TypeRef, String, Glsl.Expr.Ast)
    }

    ///
    /// Top-level construct: struct, interface block, uniform block, SSBO, push constant, or function.
    ///
    pub enum TopLevel with Eq {
        case Struct(String, Vector[BlockMember])
        case Iface(VaryingDirection, String, String, Vector[BlockMember])
        case UBlock(String, Option[String], Layout, Vector[BlockMember])
        case SBuf(String, String, Layout, Bool, Vector[BlockMember])
        case PushC(String, String, Vector[BlockMember])
        case Function(String, Glsl.Types.TypeRef, Vector[FunctionParam], Vector[Stmt])
    }

    ///
    /// Statement: assignment, declaration, control flow, or comment.
    ///
    pub enum Stmt with Eq {
        case Assign(Glsl.Expr.Ast, Glsl.Expr.Ast)
        case AssignField(Glsl.Expr.Ast, String, Glsl.Expr.Ast)
        case Local(Glsl.Types.TypeRef, String, Glsl.Expr.Ast)
        case LocalDefault(Glsl.Types.TypeRef, String, Glsl.Expr.Ast)
        case Const(Glsl.Types.TypeRef, String, Glsl.Expr.Ast)
        case LocalArray(Glsl.Types.TypeRef, String, Int32)
        case If(Glsl.Expr.Ast, Vector[Stmt])
        case ElseIf(Glsl.Expr.Ast, Vector[Stmt])
        case Else(Vector[Stmt])
        case For(ForInit, Option[Glsl.Expr.Ast], Option[Glsl.Expr.Ast], Vector[Stmt])
        case While(Glsl.Expr.Ast, Vector[Stmt])
        case Break
        case Continue
        case Return
        case ReturnExpr(Glsl.Expr.Ast)
        case Discard
        case LineComment(String)
        case BlockComment(String)
    }

    ///
    /// Render a preprocessor directive.
    ///
    pub def renderPreprocessor(p: Preprocessor): String = match p {
        case Preprocessor.Define(name, value) => "#define ${name} ${value}"
        case Preprocessor.DefineFn(name, params, body) =>
            let paramStr = params |> Vector.join(",");
            "#define ${name}(${paramStr}) ${body}"
        case Preprocessor.Ifndef(name, value) => "#ifndef ${name}\n#define ${name} ${value}\n#endif"
        case Preprocessor.Extension(name, behavior) => "#extension ${name} : ${behavior}"
        case Preprocessor.Include(path) => "#include \"${path}\""
    }

    ///
    /// Render a block member.
    ///
    pub def renderBlockMember(m: BlockMember): String = match m {
        case BlockMember.Member(ty, name) =>
            "${Glsl.Types.renderTypeRef(ty)} ${name};"
        case BlockMember.MemberLineComment(text) => "// ${text}"
        case BlockMember.MemberBlockComment(text) => "/* ${text} */"
    }

    ///
    /// Render a function parameter.
    ///
    pub def renderFunctionParam(p: FunctionParam): String = match p {
        case FunctionParam.Param(qualifier, ty, name) =>
            let qual = match qualifier {
                case ParamQualifier.Plain => ""
                case ParamQualifier.Inout => "inout "
                case ParamQualifier.Const => "const "
            };
            "${qual}${Glsl.Types.renderTypeRef(ty)} ${name}"
    }

    ///
    /// Render a for loop initializer.
    ///
    pub def renderForInit(init: ForInit): String = match init {
        case ForInit.ForInitDecl(ty, name, value) =>
            "${Glsl.Types.renderTypeRef(ty)} ${name} = ${Glsl.Expr.render(value)}"
        case ForInit.ForInitExpr(e) => Glsl.Expr.render(e)
        case ForInit.ForInitNone => ""
    }

    ///
    /// Render a uniform declaration.
    ///
    pub def renderUniform(u: Uniform): String = match u {
        case Uniform.U(ty, name, layout, precision) =>
            let layoutPart = renderLayout(layout);
            let precisionPart = match precision {
                case Some(p) => "${Glsl.Types.renderPrecision(p)} "
                case None => ""
            };
            match ty {
                case Glsl.Types.TypeRef.Array(elem, size) =>
                    let elemStr = Glsl.Types.renderTypeRef(elem);
                    "${layoutPart}uniform ${precisionPart}${elemStr} ${name}[${size}];"
                case _ =>
                    "${layoutPart}uniform ${precisionPart}${Glsl.Types.renderTypeRef(ty)} ${name};"
            }
    }

    ///
    /// Render an attribute declaration.
    ///
    pub def renderAttribute(a: Attribute): String = match a {
        case Attribute.A(location, ty, name) =>
            "layout(location = ${location}) in ${Glsl.Types.renderTypeRef(ty)} ${name};"
    }

    ///
    /// Render a varying declaration.
    ///
    pub def renderVarying(v: Varying): String = match v {
        case Varying.V(direction, ty, name) =>
            let dirStr = match direction {
                case VaryingDirection.In => "in"
                case VaryingDirection.Out => "out"
            };
            "${dirStr} ${Glsl.Types.renderTypeRef(ty)} ${name};"
    }

    ///
    /// Render an output declaration.
    ///
    pub def renderOutput(o: Output): String = match o {
        case Output.O(location, ty, name) =>
            "layout(location = ${location}) out ${Glsl.Types.renderTypeRef(ty)} ${name};"
    }

    ///
    /// Render a global variable declaration.
    ///
    pub def renderGlobal(g: Global): String = match g {
        case Global.G(ty, name, value) =>
            "${Glsl.Types.renderTypeRef(ty)} ${name} = ${Glsl.Expr.render(value)};"
    }

    ///
    /// Render a top-level construct (struct, interface block, etc.).
    /// Returns multiple lines (including indentation) as a single string.
    ///
    pub def renderTopLevel(t: TopLevel): String = match t {
        case TopLevel.Struct(name, members) =>
            let memberLines = members |> Vector.map(renderBlockMember) |> Vector.map(line -> "    ${line}");
            let inner = if (Vector.isEmpty(memberLines)) "\n" else memberLines |> Vector.toList |> String.unlines;
            "struct ${name} {\n${inner}}"
        case TopLevel.Iface(direction, name, instanceName, members) =>
            let dirStr = match direction {
                case VaryingDirection.In => "in"
                case VaryingDirection.Out => "out"
            };
            let memberLines = members |> Vector.map(renderBlockMember) |> Vector.map(line -> "    ${line}");
            "${dirStr} struct ${name} {\n${memberLines |> Vector.toList |> String.unlines}} ${instanceName};"
        case TopLevel.UBlock(name, instanceOpt, layout, members) =>
            let layoutPart = renderLayout(layout);
            let memberLines = members |> Vector.map(renderBlockMember) |> Vector.map(line -> "    ${line}");
            let footer = match instanceOpt {
                case Some(inst) => " ${inst};"
                case None => ";"
            };
            "${layoutPart}uniform ${name} {\n${memberLines |> Vector.toList |> String.unlines}}${footer}"
        case TopLevel.SBuf(name, instanceName, layout, readonly, members) =>
            let layoutPart = renderLayout(layout);
            let roStr = if (readonly) "readonly " else "";
            let memberLines = members |> Vector.map(renderBlockMember) |> Vector.map(line -> "    ${line}");
            "${layoutPart}${roStr}buffer ${name} {\n${memberLines |> Vector.toList |> String.unlines}} ${instanceName};"
        case TopLevel.PushC(name, instanceName, members) =>
            let memberLines = members |> Vector.map(renderBlockMember) |> Vector.map(line -> "    ${line}");
            "layout(push_constant) uniform ${name} {\n${memberLines |> Vector.toList |> String.unlines}} ${instanceName};"
        case TopLevel.Function(name, retType, params, body) =>
            let retTypeStr = Glsl.Types.renderTypeRef(retType);
            let paramStr = params |> Vector.map(renderFunctionParam) |> Vector.join(", ");
            let bodyLines = renderStmtVector(body) |> Vector.map(line -> "    ${line}");
            "${retTypeStr} ${name}(${paramStr}) {\n${bodyLines |> Vector.toList |> String.unlines}"+"}"
    }

    ///
    /// Render a statement. Returns a vector of strings (lines).
    /// Multi-line statements (if/while/for) produce multiple lines.
    ///
    pub def renderStmt(s: Stmt): Vector[String] = match s {
        case Stmt.Assign(lhs, rhs) => Vector#{"${Glsl.Expr.render(lhs)} = ${Glsl.Expr.render(rhs)};"}
        case Stmt.AssignField(parent, field, rhs) => Vector#{"${Glsl.Expr.render(parent)}.${field} = ${Glsl.Expr.render(rhs)};"}
        case Stmt.Local(ty, name, value) => Vector#{"${Glsl.Types.renderTypeRef(ty)} ${name} = ${Glsl.Expr.render(value)};"}
        case Stmt.LocalDefault(ty, name, default) => Vector#{"${Glsl.Types.renderTypeRef(ty)} ${name} = ${Glsl.Expr.render(default)};"}
        case Stmt.Const(ty, name, value) => Vector#{"const ${Glsl.Types.renderTypeRef(ty)} ${name} = ${Glsl.Expr.render(value)};"}
        case Stmt.LocalArray(ty, name, size) => Vector#{"${Glsl.Types.renderTypeRef(ty)} ${name}[${size}];"}
        case Stmt.If(cond, body) =>
            let bodyLines = renderStmtVector(body);
            Vector.append(Vector#{"if (${Glsl.Expr.render(cond)}) {"},
                          Vector.append(bodyLines, Vector#{"}"}))
        case Stmt.ElseIf(cond, body) =>
            let bodyLines = renderStmtVector(body);
            Vector.append(Vector#{"else if (${Glsl.Expr.render(cond)}) {"},
                          Vector.append(bodyLines, Vector#{"}"}))
        case Stmt.Else(body) =>
            let bodyLines = renderStmtVector(body);
            Vector.append(Vector#{"else {"}, Vector.append(bodyLines, Vector#{"}"}))
        case Stmt.For(init, cond, incr, body) =>
            let initStr = renderForInit(init);
            let condStr = match cond {
                case Some(e) => Glsl.Expr.render(e)
                case None => ""
            };
            let incrStr = match incr {
                case Some(e) => Glsl.Expr.render(e)
                case None => ""
            };
            let bodyLines = renderStmtVector(body);
            Vector.append(Vector#{"for (${initStr}; ${condStr}; ${incrStr}) {"},
                          Vector.append(bodyLines, Vector#{"}"}))
        case Stmt.While(cond, body) =>
            let bodyLines = renderStmtVector(body);
            Vector.append(Vector#{"while (${Glsl.Expr.render(cond)}) {"},
                          Vector.append(bodyLines, Vector#{"}"}))
        case Stmt.Break => Vector#{"break;"}
        case Stmt.Continue => Vector#{"continue;"}
        case Stmt.Return => Vector#{"return;"}
        case Stmt.ReturnExpr(e) => Vector#{"return ${Glsl.Expr.render(e)};"}
        case Stmt.Discard => Vector#{"discard;"}
        case Stmt.LineComment(text) => Vector#{"// ${text}"}
        case Stmt.BlockComment(text) => Vector#{"/* ${text} */"}
    }

    ///
    /// Helper: render a vector of statements into a flat vector of lines.
    ///
    def renderStmtVector(stmts: Vector[Stmt]): Vector[String] =
        stmts |> Vector.flatMap(renderStmt)

}
