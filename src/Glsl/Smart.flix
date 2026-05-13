///
/// `Glsl.Smart` — user-facing helpers that build `Expr[t]` values and
/// emit declarations / statements through the `Build` effect.
///
/// Smart constructors return values while emitting declarations as a side
/// effect via the Build effect. For example, `let mvp = uniform("mvp")`
/// emits the declaration and returns an Expr reference in one call.
///
pub mod Glsl.Smart {

    use Glsl.Types.GlslType
    use Glsl.Types.GlslArray
    use Glsl.Expr.Expr
    use Glsl.Expr.Ast
    use Glsl.Expr.render
    use Glsl.Expr.renderExpr
    use Glsl.Expr.erase
    use Glsl.Build.Build
    use Glsl.Ast.{LayoutItem, Layout, VaryingDirection, ParamQualifier, Preprocessor, BlockMember, FunctionParam, ForInit, Uniform, Attribute, Varying, Output, Global, TopLevel, Stmt}

    ///
    /// Declares an extension directive.
    /// Example: `extension("GL_ARB_separate_shader_objects", "enable")`
    /// produces: `#extension GL_ARB_separate_shader_objects : enable`
    ///
    pub def extension(name: String, behavior: String): Unit \ Build =
        Build.declPreprocessor(Preprocessor.Extension(name, behavior))

    ///
    /// Declares an include directive.
    /// Example: `include("common.glsl")`
    /// produces: `#include "common.glsl"`
    ///
    pub def include(path: String): Unit \ Build =
        Build.declPreprocessor(Preprocessor.Include(path))

    ///
    /// Declares a preprocessor define macro.
    /// Example: `define("PI", "3.14159")`
    /// produces: `#define PI 3.14159`
    ///
    pub def define(name: String, value: String): Unit \ Build =
        Build.declPreprocessor(Preprocessor.Define(name, value))

    ///
    /// Declares a function-like preprocessor macro.
    /// Example: `defineFn("MAX", "a,b", "((a)>(b)?(a):(b))")`
    /// produces: `#define MAX(a,b) ((a)>(b)?(a):(b))`
    ///
    pub def defineFn(name: String, params: String, body: String): Unit \ Build =
        let paramVec = params |> String.split({regex = ","}) |> List.toVector;
        Build.declPreprocessor(Preprocessor.DefineFn(name, paramVec, body))

    ///
    /// Declares a guarded #ifndef block with a default value.
    /// Example: `ifndef("DEBUG", "0")`
    /// produces:
    ///   #ifndef DEBUG
    ///   #define DEBUG 0
    ///   #endif
    ///
    pub def ifndef(macro: String, value: String): Unit \ Build =
        Build.declPreprocessor(Preprocessor.Ifndef(macro, value))

    ///
    /// Declares a uniform of type `t` with the given name and returns an
    /// `Expr[t]` referring to it. Re-declaring a name within the same
    /// `runBuild` call emits the line again — call sites must avoid that.
    /// In idiomatic use, smart constructors are called once per `let`
    /// binding, so deduplication is unnecessary.
    ///
    pub def uniform(name: String): Expr[t] \ Build with GlslType[t] =
        let ty = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        Build.declUniform(Uniform.U(ty, name, Vector#{}, None));
        Expr.Of(Ast.Var(name))

    ///
    /// Declares a vertex attribute (`layout(location = N) in T name;`).
    ///
    pub def attribute(location: Int32, name: String): Expr[t] \ Build with GlslType[t] =
        let ty = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        Build.declAttribute(Attribute.A(location, ty, name));
        Expr.Of(Ast.Var(name))

    ///
    /// Declares a varying (`out T name;` in vertex stage,
    /// `in T name;` in fragment stage). The caller must emit the
    /// matching declaration in the other stage.
    ///
    pub def varying(direction: String, name: String): Expr[t] \ Build with GlslType[t] =
        let ty = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        let dir = match direction {
            case "in"  => VaryingDirection.In
            case "out" => VaryingDirection.Out
            case _     => VaryingDirection.Out
        };
        Build.declVarying(Varying.V(dir, ty, name));
        Expr.Of(Ast.Var(name))

    ///
    /// Declares a fragment output at the given location.
    ///
    pub def output(location: Int32, name: String): Expr[t] \ Build with GlslType[t] =
        let ty = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        Build.declOutput(Output.O(location, ty, name));
        Expr.Of(Ast.Var(name))

    ///
    /// `lhs = rhs;` — assignment statement.
    ///
    pub def assign(lhs: Expr[t], rhs: Expr[t]): Unit \ Build =
        Build.emitStmt(Stmt.Assign(erase(lhs), erase(rhs)))

    ///
    /// `T name = rhs;` — declares and initialises a local variable.
    ///
    pub def localVar(name: String, rhs: Expr[t]): Expr[t] \ Build with GlslType[t] =
        let ty = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        Build.emitStmt(Stmt.Local(ty, name, erase(rhs)));
        Expr.Of(Ast.Var(name))

    ///
    /// `float name = 0.0;` — shorthand for zero-initialised local.
    ///
    pub def floatVar(name: String): Expr[Float32] \ Build =
        localVar(name, Glsl.Builtin.litF(0.0f32))

    ///
    /// `vec2 name = vec2(0.0, 0.0);`
    ///
    pub def vec2Var(name: String): Expr[Glsl.Types.Vec2] \ Build =
        localVar(name, Glsl.Builtin.vec2(Glsl.Builtin.litF(0.0f32), Glsl.Builtin.litF(0.0f32)))

    ///
    /// `vec3 name = vec3(0.0, 0.0, 0.0);`
    ///
    pub def vec3Var(name: String): Expr[Glsl.Types.Vec3] \ Build =
        localVar(name, Glsl.Builtin.vec3(Glsl.Builtin.litF(0.0f32), Glsl.Builtin.litF(0.0f32), Glsl.Builtin.litF(0.0f32)))

    ///
    /// `vec4 name = vec4(0.0, 0.0, 0.0, 0.0);`
    ///
    pub def vec4Var(name: String): Expr[Glsl.Types.Vec4] \ Build =
        localVar(name, Glsl.Builtin.vec4(Glsl.Builtin.litF(0.0f32), Glsl.Builtin.litF(0.0f32), Glsl.Builtin.litF(0.0f32), Glsl.Builtin.litF(0.0f32)))

    ///
    /// `int name = 0;`
    ///
    pub def intVar(name: String): Expr[Int32] \ Build =
        localVar(name, Glsl.Builtin.litI(0))

    ///
    /// `uniform T name[size];` — fixed-size uniform array declaration.
    ///
    pub def uniformArray(name: String, size: Int32): Expr[GlslArray[t]] \ Build with GlslType[t] =
        let elemTy = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        let arrayTy = Glsl.Types.TypeRef.Array(elemTy, size);
        Build.declUniform(Uniform.U(arrayTy, name, Vector#{}, None));
        Expr.Of(Ast.Var(name))

    ///
    /// `T name[size];` — fixed-size local array declaration.
    ///
    pub def localArray(name: String, size: Int32): Expr[GlslArray[t]] \ Build with GlslType[t] =
        let elemTy = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        let arrayTy = Glsl.Types.TypeRef.Array(elemTy, size);
        Build.emitStmt(Stmt.LocalArray(arrayTy, name, size));
        Expr.Of(Ast.Var(name))

    ///
    /// `discard;` — fragment-stage early exit. (`discard` is a Flix
    /// reserved word, so the helper is named `discardFrag`.)
    ///
    pub def discardFrag(): Unit \ Build =
        Build.emitStmt(Stmt.Discard)

    ///
    /// `v.field = rhs;` — swizzle / component write.
    ///
    /// This validates the "lvalue swizzle" question from
    /// `ADDITIONAL_INSIGHTS.md`. We emit the assignment verbatim —
    /// no host-side mirror, no record `with` gymnastics. In Flix the
    /// AST is the truth, so the assignment goes straight through.
    ///
    pub def assignField(parent: Expr[a], field: String, rhs: Expr[b]): Unit \ Build =
        Build.emitStmt(Stmt.AssignField(erase(parent), field, erase(rhs)))

    ///
    /// `if (cond) { body }` — conditional block.
    ///
    pub def ifStmt(cond: Expr[Bool], body: Unit -> Unit \ Build): Unit \ Build = {
        let bodyStmts = Glsl.Build.captureBody(body);
        Build.emitStmt(Stmt.If(erase(cond), bodyStmts))
    }

    ///
    /// `else if (cond) { body }`.
    ///
    pub def elseIfStmt(cond: Expr[Bool], body: Unit -> Unit \ Build): Unit \ Build = {
        let bodyStmts = Glsl.Build.captureBody(body);
        Build.emitStmt(Stmt.ElseIf(erase(cond), bodyStmts))
    }

    ///
    /// `else { body }`.
    ///
    pub def elseStmt(body: Unit -> Unit \ Build): Unit \ Build = {
        let bodyStmts = Glsl.Build.captureBody(body);
        Build.emitStmt(Stmt.Else(bodyStmts))
    }

    ///
    /// `for (init; cond; incr) { body }` — for loop.
    /// Legacy version: init and incr are string-based (wrapped in ForInitExpr/Lit).
    ///
    pub def forLoop(init: String, cond: Expr[Bool], incr: String, body: Unit -> Unit \ Build): Unit \ Build = {
        let initAst = ForInit.ForInitExpr(Ast.Lit(init));
        let incrAst = Some(Ast.Lit(incr));
        let bodyStmts = Glsl.Build.captureBody(body);
        Build.emitStmt(Stmt.For(initAst, Some(erase(cond)), incrAst, bodyStmts))
    }

    ///
    /// `while (cond) { body }` — while loop.
    ///
    pub def whileLoop(cond: Expr[Bool], body: Unit -> Unit \ Build): Unit \ Build = {
        let bodyStmts = Glsl.Build.captureBody(body);
        Build.emitStmt(Stmt.While(erase(cond), bodyStmts))
    }

    ///
    /// `break;` — loop exit.
    ///
    pub def breakStmt(): Unit \ Build =
        Build.emitStmt(Stmt.Break)

    ///
    /// `continue;` — loop skip.
    ///
    pub def continueStmt(): Unit \ Build =
        Build.emitStmt(Stmt.Continue)

    ///
    /// Defines a top-level GLSL function.
    /// Legacy version: params are string-based (e.g., ["float x", "vec3 y"]).
    /// The params are parsed to extract type and name information.
    ///
    pub def defineFunction(name: String, retType: Proxy[r], params: List[String], body: Unit -> Unit \ Build): Unit \ Build with GlslType[r] = {
        let retTy = GlslType.typeRef(retType);
        let paramAsts = params |> List.map(parseParamString) |> List.toVector;
        let bodyStmts = Glsl.Build.captureBody(body);
        Build.declTopLevel(TopLevel.Function(name, retTy, paramAsts, bodyStmts))
    }

    ///
    /// Helper to create a typed parameter string for `defineFunction`.
    ///
    pub def param(name: String, p: Proxy[t]): String with GlslType[t] =
        "${Glsl.Types.typeName(p)} ${name}"

    ///
    /// `return;` or `return expr;`.
    ///
    pub def returnStmt(): Unit \ Build =
        Build.emitStmt(Stmt.Return)

    ///
    /// `return expr;`.
    ///
    pub def returnExpr(e: Expr[t]): Unit \ Build =
        Build.emitStmt(Stmt.ReturnExpr(erase(e)))

    ///
    /// Declares a uniform with a `binding = N` layout qualifier.
    ///
    pub def uniformWithBinding(name: String, binding: Int32): Expr[t] \ Build with GlslType[t] =
        let ty = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        Build.declUniform(Uniform.U(ty, name, Vector#{LayoutItem.Binding(binding)}, None));
        Expr.Of(Ast.Var(name))

    ///
    /// Declares a uniform with a precision qualifier.
    ///
    pub def uniformWithPrecision(name: String, precisionStr: String): Expr[t] \ Build with GlslType[t] =
        let ty = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        let precision = match precisionStr {
            case "highp"   => Some(Glsl.Types.Precision.Highp)
            case "mediump" => Some(Glsl.Types.Precision.Mediump)
            case "lowp"    => Some(Glsl.Types.Precision.Lowp)
            case _         => None
        };
        Build.declUniform(Uniform.U(ty, name, Vector#{}, precision));
        Expr.Of(Ast.Var(name))

    ///
    /// Declares a uniform with optional layout binding and/or precision qualifier.
    ///
    pub def uniformWithLayoutAndPrecision(name: String, binding: Option[Int32], precisionStr: Option[String]): Expr[t] \ Build with GlslType[t] =
        let ty = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        let layout = match binding {
            case Some(b) => Vector#{LayoutItem.Binding(b)}
            case None    => Vector#{}
        };
        let precision = match precisionStr {
            case Some("highp")   => Some(Glsl.Types.Precision.Highp)
            case Some("mediump") => Some(Glsl.Types.Precision.Mediump)
            case Some("lowp")    => Some(Glsl.Types.Precision.Lowp)
            case _               => None
        };
        Build.declUniform(Uniform.U(ty, name, layout, precision));
        Expr.Of(Ast.Var(name))

    ///
    /// Declares a uniform interface block with the given name, binding point, and member definitions.
    /// The builder function emits block members.
    ///
    pub def declareUniformBlock(blockName: String, builder: (Unit -> Unit \ Build), binding: Int32): Unit \ Build =
        let layout = Vector#{LayoutItem.Std140, LayoutItem.Binding(binding)};
        let members = Glsl.Build.captureMembers(builder);
        Build.declTopLevel(TopLevel.UBlock(blockName, None, layout, members))

    ///
    /// Declares a single-member uniform interface block with the given block name, member type, and binding.
    ///
    pub def declareUniformBlockMember(blockName: String, memberName: String, binding: Int32): Expr[t] \ Build with GlslType[t] =
        let memberType = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        let layout = Vector#{LayoutItem.Std140, LayoutItem.Binding(binding)};
        let members = Vector#{BlockMember.Member(memberType, memberName)};
        Build.declTopLevel(TopLevel.UBlock(blockName, None, layout, members));
        Expr.Of(Ast.Field(Ast.Var(blockName), memberName))

    ///
    /// Accesses a member of a uniform block using dot notation.
    ///
    pub def blockAccess(block: Expr[a], member: String): Expr[t] =
        Expr.Of(Ast.Field(erase(block), member))

    ///
    /// Built-in vertex output: `gl_Position` (vec4).
    /// Available in vertex stage only.
    ///
    pub def glPosition(): Expr[Glsl.Types.Vec4] =
        Expr.Of(Ast.Var("gl_Position"))

    ///
    /// Built-in fragment input: `gl_FragCoord` (vec4, screen-space coords + depth).
    /// Available in fragment stage only.
    ///
    pub def glFragCoord(): Expr[Glsl.Types.Vec4] =
        Expr.Of(Ast.Var("gl_FragCoord"))

    ///
    /// Built-in fragment input: `gl_FrontFacing` (bool).
    /// Available in fragment stage only.
    ///
    pub def glFrontFacing(): Expr[Bool] =
        Expr.Of(Ast.Var("gl_FrontFacing"))

    ///
    /// Built-in multiview input: `gl_ViewIndex` (uint, zero in non-multiview).
    /// Available in both vertex and fragment stages.
    ///
    pub def glViewIndex(): Expr[Glsl.Types.UInt32] =
        Expr.Of(Ast.Var("gl_ViewIndex"))

    ///
    /// Declares a const local variable: `const T name = rhs;`
    ///
    pub def constVar(name: String, rhs: Expr[t]): Expr[t] \ Build with GlslType[t] =
        let ty = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        Build.emitStmt(Stmt.Const(ty, name, erase(rhs)));
        Expr.Of(Ast.Var(name))

    ///
    /// Declares a sampler with set and binding qualifiers (Vulkan descriptor sets).
    /// Example: `layout(set = 0, binding = 1) uniform sampler2D albedoSampler;`
    ///
    pub def samplerWithLayout(name: String, set: Int32, binding: Int32): Expr[t] \ Build with GlslType[t] =
        let ty = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        let layout = Vector#{LayoutItem.Set(set), LayoutItem.Binding(binding)};
        Build.declUniform(Uniform.U(ty, name, layout, None));
        Expr.Of(Ast.Var(name))

    ///
    /// Declares a uniform with set and binding qualifiers (Vulkan descriptor sets).
    /// Example: `layout(set = 3, binding = 0) uniform vec4 myUniform;`
    ///
    pub def uniformWithSet(name: String, set: Int32, binding: Int32): Expr[t] \ Build with GlslType[t] =
        let ty = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        let layout = Vector#{LayoutItem.Set(set), LayoutItem.Binding(binding)};
        Build.declUniform(Uniform.U(ty, name, layout, None));
        Expr.Of(Ast.Var(name))

    ///
    /// Declares a uniform interface block with multiple members.
    /// The builder function emits block members via uniformBlockMember calls.
    /// Example:
    ///   declareUniformBlockMulti("CustomUniform", "M", Some(3), 0, _ -> {
    ///       uniformBlockMember("pointers");
    ///       uniformBlockMember("z_span");
    ///   })
    /// Produces:
    ///   layout(std140, set = 3, binding = 0) uniform CustomUniform {
    ///       vec4 pointers;
    ///       vec4 z_span;
    ///   } M;
    ///
    pub def declareUniformBlockMulti(
        blockName: String,
        instanceName: String,
        set: Option[Int32],
        binding: Int32,
        builder: Unit -> Unit \ Build): Unit \ Build =
        let layout = match set {
            case Some(s) => Vector#{LayoutItem.Std140, LayoutItem.Set(s), LayoutItem.Binding(binding)}
            case None    => Vector#{LayoutItem.Std140, LayoutItem.Binding(binding)}
        };
        let members = Glsl.Build.captureMembers(builder);
        Build.declTopLevel(TopLevel.UBlock(blockName, Some(instanceName), layout, members))

    ///
    /// Emits a uniform block member declaration within a uniform block.
    /// Must be called within a declareUniformBlockMulti builder.
    /// Example: `uniformBlockMember("myFloat")` produces `float myFloat;`
    ///
    pub def uniformBlockMember(name: String): Expr[t] \ Build with GlslType[t] =
        uniformBlockMemberTyped(name, Proxy.Proxy)

    ///
    /// Emits a uniform block member declaration with explicit type.
    /// This variant is useful when you need to specify the exact type for the member.
    /// Must be called within a declareUniformBlockMulti builder.
    ///
    pub def uniformBlockMemberTyped(name: String, typeProxy: Proxy[t]): Expr[t] \ Build with GlslType[t] =
        let ty = GlslType.typeRef(typeProxy);
        Build.emitMember(BlockMember.Member(ty, name));
        Expr.Of(Ast.Var(name))
///
/// Declares a named GLSL struct.
/// Example:
///   declareStruct("Light", _ -> {
///       discard structMember("pos", (Proxy.Proxy: Proxy[Vec3]));
///       discard structMember("color", (Proxy.Proxy: Proxy[Vec3]));
///   })
///
    pub def declareStruct(name: String, builder: Unit -> Unit \ Build): Unit \ Build =
        let members = Glsl.Build.captureMembers(builder);
        Build.declTopLevel(TopLevel.Struct(name, members))

    ///
    /// Emits a struct member declaration. Must be called within declareStruct.
    ///
    pub def structMember(name: String): Expr[t] \ Build with GlslType[t] =
        structMemberTyped(name, Proxy.Proxy)

    ///
    /// Emits a struct member declaration with explicit type.
    ///
    pub def structMemberTyped(name: String, typeProxy: Proxy[t]): Expr[t] \ Build with GlslType[t] =
        let ty = GlslType.typeRef(typeProxy);
        Build.emitMember(BlockMember.Member(ty, name));
        Expr.Of(Ast.Var(name))

    ///
    /// Declares an interface block (struct in/out).
    /// Example:
    ///   declareInterfaceBlock("in", "VertexOut", "vertexOut", _ -> {
    ///       discard structMember("color", (Proxy.Proxy: Proxy[Vec4]));
    ///   })
    ///
    pub def declareInterfaceBlock(direction: String, name: String, instanceName: String, builder: Unit -> Unit \ Build): Unit \ Build =
        let dir = match direction {
            case "in"  => VaryingDirection.In
            case "out" => VaryingDirection.Out
            case _     => VaryingDirection.Out
        };
        let members = Glsl.Build.captureMembers(builder);
        Build.declTopLevel(TopLevel.Iface(dir, name, instanceName, members))

    ///
    /// Declares a global variable with a runtime-initialised value.
    /// Example: `globalVar("plotShape", call("uint", List#{...}))`
    /// produces: `uint plotShape = uint(...);`
    /// Note: global variables are placed in the globals section, before main().
    ///
    pub def globalVar(name: String, rhs: Expr[t]): Expr[t] \ Build with GlslType[t] =
        let ty = GlslType.typeRef((Proxy.Proxy: Proxy[t]));
        Build.declGlobal(Global.G(ty, name, erase(rhs)));
        Expr.Of(Ast.Var(name))

    ///
    /// Declares a storage buffer (SSBO) with set and binding layout qualifiers.
    /// Example:
    ///   storageBuffer("StorageBuf", "storage", 3, 6, _ -> {
    ///       uniformBlockMember("data");
    ///   })
    /// produces:
    ///   layout(set=3, binding=6) readonly buffer StorageBuf {
    ///       vec4 data;
    ///   } storage;
    ///
    pub def storageBuffer(
        bufferName: String,
        instanceName: String,
        set: Int32,
        binding: Int32,
        builder: Unit -> Unit \ Build): Unit \ Build =
        let layout = Vector#{LayoutItem.Set(set), LayoutItem.Binding(binding)};
        let members = Glsl.Build.captureMembers(builder);
        Build.declTopLevel(TopLevel.SBuf(bufferName, instanceName, layout, true, members))

    ///
    /// Declares a push constant uniform block.
    /// Example:
    ///   pushConstant("PushConsts", "pc", _ -> {
    ///       uniformBlockMember("stereoPassId");
    ///   })
    /// produces:
    ///   layout(push_constant) uniform PushConsts {
    ///       uint stereoPassId;
    ///   } pc;
    ///
    pub def pushConstant(
        blockName: String,
        instanceName: String,
        builder: Unit -> Unit \ Build): Unit \ Build =
        let members = Glsl.Build.captureMembers(builder);
        Build.declTopLevel(TopLevel.PushC(blockName, instanceName, members))

    ///
    /// Creates a parameter string for an inout parameter in a function definition.
    /// Example: `param("value", (Proxy.Proxy: Proxy[Float32]))` produces `"inout float value"`
    ///
    pub def inoutParam(name: String, p: Proxy[t]): String with GlslType[t] =
        "inout ${Glsl.Types.typeName(p)} ${name}"

    ///
    /// Creates a parameter string for a const parameter in a function definition.
    /// Example: `param("value", (Proxy.Proxy: Proxy[Vec3]))` produces `"const vec3 value"`
    ///
    pub def constParam(name: String, p: Proxy[t]): String with GlslType[t] =
        "const ${Glsl.Types.typeName(p)} ${name}"

    ///
    /// Emits a single-line comment: `// text`
    /// Note: when called within a function or control flow body, this emits a Stmt.LineComment.
    /// When called within a block (struct/uniform block), use commentMember instead.
    ///
    pub def comment(text: String): Unit \ Build =
        Build.emitStmt(Stmt.LineComment(text))

    ///
    /// Emits a block comment: `/* text */`
    /// Note: when called within a function or control flow body, this emits a Stmt.BlockComment.
    /// When called within a block (struct/uniform block), use commentBlockMember instead.
    ///
    pub def blockComment(text: String): Unit \ Build =
        Build.emitStmt(Stmt.BlockComment(text))

    ///
    /// Emits a single-line member comment within a struct or uniform block.
    ///
    pub def commentMember(text: String): Unit \ Build =
        Build.emitMember(BlockMember.MemberLineComment(text))

    ///
    /// Emits a block member comment within a struct or uniform block.
    ///
    pub def commentBlockMember(text: String): Unit \ Build =
        Build.emitMember(BlockMember.MemberBlockComment(text))

    ///
    /// Internal: parses a legacy parameter string like "float x" or "const vec3 y" into a FunctionParam.
    /// Handles const, inout, and plain qualifiers.
    ///
    def parseParamString(paramStr: String): FunctionParam = {
        let tokens = paramStr |> String.trim |> String.split({regex = " "}) |> List.filter(s -> not String.isEmpty(s));
        let (qual, typeTokens) = match tokens {
            case "const" :: rest => (ParamQualifier.Const, rest)
            case "inout" :: rest => (ParamQualifier.Inout, rest)
            case ts              => (ParamQualifier.Plain, ts)
        };
        let (ty, name) = match List.reverse(typeTokens) {
            case n :: typeRev => (parseTypeString(List.reverse(typeRev) |> String.intercalate(" ")), n)
            case _            => (Glsl.Types.TypeRef.Named("unknown"), "unknown")
        };
        FunctionParam.Param(qual, ty, name)
    }

    ///
    /// Internal: converts a type name string (e.g., "float", "vec3", "mat4") to a TypeRef.
    ///
    def parseTypeString(typeStr: String): Glsl.Types.TypeRef = match typeStr |> String.trim {
        case "float"  => Glsl.Types.TypeRef.Float
        case "int"    => Glsl.Types.TypeRef.Int
        case "uint"   => Glsl.Types.TypeRef.UInt
        case "bool"   => Glsl.Types.TypeRef.Bool
        case "void"   => Glsl.Types.TypeRef.Void
        case "vec2"   => Glsl.Types.TypeRef.Vec2
        case "vec3"   => Glsl.Types.TypeRef.Vec3
        case "vec4"   => Glsl.Types.TypeRef.Vec4
        case "ivec2"  => Glsl.Types.TypeRef.IVec2
        case "ivec3"  => Glsl.Types.TypeRef.IVec3
        case "ivec4"  => Glsl.Types.TypeRef.IVec4
        case "uvec2"  => Glsl.Types.TypeRef.UVec2
        case "uvec3"  => Glsl.Types.TypeRef.UVec3
        case "uvec4"  => Glsl.Types.TypeRef.UVec4
        case "bvec2"  => Glsl.Types.TypeRef.BVec2
        case "bvec3"  => Glsl.Types.TypeRef.BVec3
        case "bvec4"  => Glsl.Types.TypeRef.BVec4
        case "mat2"   => Glsl.Types.TypeRef.Mat2
        case "mat3"   => Glsl.Types.TypeRef.Mat3
        case "mat4"   => Glsl.Types.TypeRef.Mat4
        case "sampler2D" => Glsl.Types.TypeRef.Sampler2D
        case "samplerCube" => Glsl.Types.TypeRef.SamplerCube
        case "sampler2DArray" => Glsl.Types.TypeRef.Sampler2DArray
        case "sampler3D" => Glsl.Types.TypeRef.Sampler3D
        case s => Glsl.Types.TypeRef.Named(s)
    }

}
