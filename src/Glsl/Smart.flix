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
    use Glsl.Expr.render
    use Glsl.Expr.boxed
    use Glsl.Build.Build

    ///
    /// Declares an extension directive.
    /// Example: `extension("GL_ARB_separate_shader_objects", "enable")`
    /// produces: `#extension GL_ARB_separate_shader_objects : enable`
    ///
    pub def extension(name: String, behavior: String): Unit \ Build =
        Build.declExtension("#extension ${name} : ${behavior}")

    ///
    /// Declares an include directive.
    /// Example: `include("common.glsl")`
    /// produces: `#include "common.glsl"`
    ///
    pub def include(path: String): Unit \ Build =
        Build.declInclude("#include \"${path}\"")

    ///
    /// Declares a preprocessor define macro.
    /// Example: `define("PI", "3.14159")`
    /// produces: `#define PI 3.14159`
    ///
    pub def define(name: String, value: String): Unit \ Build =
        Build.declDefine("#define ${name} ${value}")

    ///
    /// Declares a function-like preprocessor macro.
    /// Example: `defineFn("MAX", "a,b", "((a)>(b)?(a):(b))")`
    /// produces: `#define MAX(a,b) ((a)>(b)?(a):(b))`
    ///
    pub def defineFn(name: String, params: String, body: String): Unit \ Build =
        Build.declDefine("#define ${name}(${params}) ${body}")

    ///
    /// Declares a guarded #ifndef block with a default value.
    /// Example: `ifndef("DEBUG", "0")`
    /// produces:
    ///   #ifndef DEBUG
    ///   #define DEBUG 0
    ///   #endif
    ///
    pub def ifndef(macro: String, value: String): Unit \ Build =
        Build.declDefine("#ifndef ${macro}");
        Build.declDefine("#define ${macro} ${value}");
        Build.declDefine("#endif")

    ///
    /// Declares a uniform of type `t` with the given name and returns an
    /// `Expr[t]` referring to it. Re-declaring a name within the same
    /// `runBuild` call emits the line again — call sites must avoid that.
    /// In idiomatic use, smart constructors are called once per `let`
    /// binding, so deduplication is unnecessary.
    ///
    pub def uniform(name: String): Expr[t] \ Build with GlslType[t] =
        let typeStr = GlslType.typeName((Proxy.Proxy: Proxy[t]));
        Build.declUniform("uniform ${typeStr} ${name};");
        Expr.Var(name)

    ///
    /// Declares a vertex attribute (`layout(location = N) in T name;`).
    ///
    pub def attribute(location: Int32, name: String): Expr[t] \ Build with GlslType[t] =
        let typeStr = GlslType.typeName((Proxy.Proxy: Proxy[t]));
        Build.declAttribute("layout(location = ${location}) in ${typeStr} ${name};");
        Expr.Var(name)

    ///
    /// Declares a varying (`out T name;` in vertex stage,
    /// `in T name;` in fragment stage). The caller must emit the
    /// matching declaration in the other stage.
    ///
    pub def varying(direction: String, name: String): Expr[t] \ Build with GlslType[t] =
        let typeStr = GlslType.typeName((Proxy.Proxy: Proxy[t]));
        Build.declVarying("${direction} ${typeStr} ${name};");
        Expr.Var(name)

    ///
    /// Declares a fragment output at the given location.
    ///
    pub def output(location: Int32, name: String): Expr[t] \ Build with GlslType[t] =
        let typeStr = GlslType.typeName((Proxy.Proxy: Proxy[t]));
        Build.declOutput("layout(location = ${location}) out ${typeStr} ${name};");
        Expr.Var(name)

    ///
    /// `lhs = rhs;` — assignment statement.
    ///
    pub def assign(lhs: Expr[t], rhs: Expr[t]): Unit \ Build =
        Build.emitStmt("${render(lhs)} = ${render(rhs)};")

    ///
    /// `T name = rhs;` — declares and initialises a local variable.
    ///
    pub def localVar(name: String, rhs: Expr[t]): Expr[t] \ Build with GlslType[t] =
        let typeStr = GlslType.typeName((Proxy.Proxy: Proxy[t]));
        Build.emitStmt("${typeStr} ${name} = ${render(rhs)};");
        Expr.Var(name)

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
        let typeStr = GlslType.typeName((Proxy.Proxy: Proxy[t]));
        Build.declUniform("uniform ${typeStr} ${name}[${size}];");
        Expr.Var(name)

    ///
    /// `T name[size];` — fixed-size local array declaration.
    ///
    pub def localArray(name: String, size: Int32): Expr[GlslArray[t]] \ Build with GlslType[t] =
        let typeStr = GlslType.typeName((Proxy.Proxy: Proxy[t]));
        Build.emitStmt("${typeStr} ${name}[${size}];");
        Expr.Var(name)

    ///
    /// `discard;` — fragment-stage early exit. (`discard` is a Flix
    /// reserved word, so the helper is named `discardFrag`.)
    ///
    pub def discardFrag(): Unit \ Build =
        Build.emitStmt("discard;")

    ///
    /// `v.field = rhs;` — swizzle / component write.
    ///
    /// This validates the "lvalue swizzle" question from
    /// `ADDITIONAL_INSIGHTS.md`. We emit the assignment verbatim —
    /// no host-side mirror, no record `with` gymnastics. In Flix the
    /// AST is the truth, so the assignment goes straight through.
    ///
    pub def assignField(parent: Expr[a], field: String, rhs: Expr[b]): Unit \ Build =
        Build.emitStmt("${render(parent)}.${field} = ${render(rhs)};")

    ///
    /// `if (cond) { body }` — conditional block.
    ///
    pub def ifStmt(cond: Expr[Bool], body: Unit -> Unit \ Build): Unit \ Build = {
        Build.emitStmt("if (${render(cond)}) {");
        body();
        Build.emitStmt("}")
    }

    ///
    /// `else if (cond) { body }`.
    ///
    pub def elseIfStmt(cond: Expr[Bool], body: Unit -> Unit \ Build): Unit \ Build = {
        Build.emitStmt("else if (${render(cond)}) {");
        body();
        Build.emitStmt("}")
    }

    ///
    /// `else { body }`.
    ///
    pub def elseStmt(body: Unit -> Unit \ Build): Unit \ Build = {
        Build.emitStmt("else {");
        body();
        Build.emitStmt("}")
    }

    ///
    /// `for (init; cond; incr) { body }` — for loop.
    ///
    pub def forLoop(init: String, cond: Expr[Bool], incr: String, body: Unit -> Unit \ Build): Unit \ Build = {
        Build.emitStmt("for (${init}; ${render(cond)}; ${incr}) {");
        body();
        Build.emitStmt("}")
    }

    ///
    /// `while (cond) { body }` — while loop.
    ///
    pub def whileLoop(cond: Expr[Bool], body: Unit -> Unit \ Build): Unit \ Build = {
        Build.emitStmt("while (${render(cond)}) {");
        body();
        Build.emitStmt("}")
    }

    ///
    /// `break;` — loop exit.
    ///
    pub def breakStmt(): Unit \ Build =
        Build.emitStmt("break;")

    ///
    /// `continue;` — loop skip.
    ///
    pub def continueStmt(): Unit \ Build =
        Build.emitStmt("continue;")

    ///
    /// Defines a top-level GLSL function.
    ///
    pub def defineFunction(name: String, retType: Proxy[r], params: List[String], body: Unit -> Unit \ Build): Unit \ Build with GlslType[r] = {
        let retTypeStr = GlslType.typeName(retType);
        let sig = "${retTypeStr} ${name}(${List.join(", ", params)})";
        let bodyLines = Glsl.Build.captureBody(body);
        Build.declFunction(sig, bodyLines)
    }

    ///
    /// Helper to create a typed parameter string for `defineFunction`.
    ///
    pub def param(name: String, p: Proxy[t]): String with GlslType[t] =
        "${GlslType.typeName(p)} ${name}"

    ///
    /// `return;` or `return expr;`.
    ///
    pub def returnStmt(): Unit \ Build =
        Build.emitStmt("return;")

    ///
    /// `return expr;`.
    ///
    pub def returnExpr(e: Expr[t]): Unit \ Build =
        Build.emitStmt("return ${render(e)};")

    ///
    /// Declares a uniform with a `binding = N` layout qualifier.
    ///
    pub def uniformWithBinding(name: String, binding: Int32): Expr[t] \ Build with GlslType[t] =
        let typeStr = GlslType.typeName((Proxy.Proxy: Proxy[t]));
        Build.declUniform("layout(binding = ${binding}) uniform ${typeStr} ${name};");
        Expr.Var(name)

    ///
    /// Declares a uniform with a precision qualifier.
    ///
    pub def uniformWithPrecision(name: String, precision: String): Expr[t] \ Build with GlslType[t] =
        let typeStr = GlslType.typeName((Proxy.Proxy: Proxy[t]));
        Build.declUniform("uniform ${precision} ${typeStr} ${name};");
        Expr.Var(name)

    ///
    /// Declares a uniform with optional layout binding and/or precision qualifier.
    ///
    pub def uniformWithLayoutAndPrecision(name: String, binding: Option[Int32], precision: Option[String]): Expr[t] \ Build with GlslType[t] =
        let typeStr = GlslType.typeName((Proxy.Proxy: Proxy[t]));
        let layoutPart = match binding {
            case Some(b) => "layout(binding = ${b}) "
            case None    => ""
        };
        let precisionPart = match precision {
            case Some(p) => "${p} "
            case None    => ""
        };
        Build.declUniform("${layoutPart}uniform ${precisionPart}${typeStr} ${name};");
        Expr.Var(name)

    ///
    /// Declares a uniform interface block with the given name, binding point, and member definitions.
    /// The builder function emits block members as statements.
    ///
    pub def declareUniformBlock(blockName: String, builder: (Unit -> Unit \ Build), binding: Int32): Unit \ Build =
        let sig = "layout(std140, binding = ${binding}) uniform ${blockName}";
        let bodyLines = Glsl.Build.captureBody(builder);
        Build.declFunction(sig, bodyLines)

    ///
    /// Declares a single-member uniform interface block with the given block name, member type, and binding.
    ///
    pub def declareUniformBlockMember(blockName: String, memberName: String, binding: Int32): Expr[t] \ Build with GlslType[t] =
        let memberType = GlslType.typeName((Proxy.Proxy: Proxy[t]));
        let sig = "layout(std140, binding = ${binding}) uniform ${blockName}";
        let bodyLines = Vector#{" ${memberType} ${memberName};"};
        Build.declFunction(sig, bodyLines);
        Expr.Field(boxed(Expr.Var(blockName)), memberName)

    ///
    /// Accesses a member of a uniform block using dot notation.
    ///
    pub def blockAccess(block: Expr[a], member: String): Expr[t] =
        Expr.Field(boxed(block), member)

    ///
    /// Built-in vertex output: `gl_Position` (vec4).
    /// Available in vertex stage only.
    ///
    pub def glPosition(): Expr[Glsl.Types.Vec4] =
        Expr.Var("gl_Position")

    ///
    /// Built-in fragment input: `gl_FragCoord` (vec4, screen-space coords + depth).
    /// Available in fragment stage only.
    ///
    pub def glFragCoord(): Expr[Glsl.Types.Vec4] =
        Expr.Var("gl_FragCoord")

    ///
    /// Built-in fragment input: `gl_FrontFacing` (bool).
    /// Available in fragment stage only.
    ///
    pub def glFrontFacing(): Expr[Bool] =
        Expr.Var("gl_FrontFacing")

    ///
    /// Built-in multiview input: `gl_ViewIndex` (uint, zero in non-multiview).
    /// Available in both vertex and fragment stages.
    ///
    pub def glViewIndex(): Expr[Glsl.Types.UInt32] =
        Expr.Var("gl_ViewIndex")

    ///
    /// Declares a const local variable: `const T name = rhs;`
    ///
    pub def constVar(name: String, rhs: Expr[t]): Expr[t] \ Build with GlslType[t] =
        let typeStr = GlslType.typeName((Proxy.Proxy: Proxy[t]));
        Build.emitStmt("const ${typeStr} ${name} = ${render(rhs)};");
        Expr.Var(name)

    ///
    /// Declares a sampler with set and binding qualifiers (Vulkan descriptor sets).
    /// Example: `layout(set = 0, binding = 1) uniform sampler2D albedoSampler;`
    ///
    pub def samplerWithLayout(name: String, set: Int32, binding: Int32): Expr[t] \ Build with GlslType[t] =
        let typeStr = GlslType.typeName((Proxy.Proxy: Proxy[t]));
        Build.declUniform("layout(set = ${set}, binding = ${binding}) uniform ${typeStr} ${name};");
        Expr.Var(name)

    ///
    /// Declares a uniform with set and binding qualifiers (Vulkan descriptor sets).
    /// Example: `layout(set = 3, binding = 0) uniform vec4 myUniform;`
    ///
    pub def uniformWithSet(name: String, set: Int32, binding: Int32): Expr[t] \ Build with GlslType[t] =
        let typeStr = GlslType.typeName((Proxy.Proxy: Proxy[t]));
        Build.declUniform("layout(set = ${set}, binding = ${binding}) uniform ${typeStr} ${name};");
        Expr.Var(name)

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
        let layoutPart = match set {
            case Some(s) => "layout(std140, set = ${s}, binding = ${binding})"
            case None    => "layout(std140, binding = ${binding})"
        };
        let sig = "${layoutPart} uniform ${blockName}";
        let bodyLines = Glsl.Build.captureBody(builder);
        Build.declBlock(sig, bodyLines, " ${instanceName};")

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
        let typeStr = GlslType.typeName(typeProxy);
        Build.emitStmt("${typeStr} ${name};");
        Expr.Var(name)
///
/// Declares a named GLSL struct.
/// Example:
///   declareStruct("Light", _ -> {
///       discard structMember("pos", (Proxy.Proxy: Proxy[Vec3]));
///       discard structMember("color", (Proxy.Proxy: Proxy[Vec3]));
///   })
///
pub def declareStruct(name: String, builder: Unit -> Unit \ Build): Unit \ Build =
    let sig = "struct ${name}";
    let bodyLines = Glsl.Build.captureBody(builder);
    Build.declBlock(sig, bodyLines, ";")

///
/// Emits a struct member declaration. Must be called within declareStruct.
///
pub def structMember(name: String): Expr[t] \ Build with GlslType[t] =
    structMemberTyped(name, Proxy.Proxy)

///
/// Emits a struct member declaration with explicit type.
///
pub def structMemberTyped(name: String, typeProxy: Proxy[t]): Expr[t] \ Build with GlslType[t] =
    let typeStr = GlslType.typeName(typeProxy);
    Build.emitStmt("${typeStr} ${name};");
    Expr.Var(name)

///
/// Declares an interface block (struct in/out).
/// Example:
///   declareInterfaceBlock("in", "VertexOut", "vertexOut", _ -> {
///       discard structMember("color", (Proxy.Proxy: Proxy[Vec4]));
///   })
///
pub def declareInterfaceBlock(direction: String, name: String, instanceName: String, builder: Unit -> Unit \ Build): Unit \ Build =
    let sig = "${direction} struct ${name}";
    let bodyLines = Glsl.Build.captureBody(builder);
    Build.declBlock(sig, bodyLines, " ${instanceName};")

///
/// Declares a global variable with a runtime-initialised value.
/// Example: `globalVar("plotShape", call("uint", List#{...}))`
/// produces: `uint plotShape = uint(...);`
/// Note: global variables are placed in the globals section, before main().
///
pub def globalVar(name: String, rhs: Expr[t]): Expr[t] \ Build with GlslType[t] =
    let typeStr = GlslType.typeName((Proxy.Proxy: Proxy[t]));
    Build.declGlobal("${typeStr} ${name} = ${Glsl.Expr.render(rhs)};");
    Expr.Var(name)

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
    let sig = "layout(set = ${set}, binding = ${binding}) readonly buffer ${bufferName}";
    let bodyLines = Glsl.Build.captureBody(builder);
    Build.declBlock(sig, bodyLines, " ${instanceName};")

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
    let sig = "layout(push_constant) uniform ${blockName}";
    let bodyLines = Glsl.Build.captureBody(builder);
    Build.declBlock(sig, bodyLines, " ${instanceName};")

///
/// Creates a parameter string for an inout parameter in a function definition.
/// Example: `param("value", (Proxy.Proxy: Proxy[Float32]))` produces `"inout float value"`
///
pub def inoutParam(name: String, p: Proxy[t]): String with GlslType[t] =
    "inout ${GlslType.typeName(p)} ${name}"

///
/// Creates a parameter string for a const parameter in a function definition.
/// Example: `param("value", (Proxy.Proxy: Proxy[Vec3]))` produces `"const vec3 value"`
///
pub def constParam(name: String, p: Proxy[t]): String with GlslType[t] =
    "const ${GlslType.typeName(p)} ${name}"

///
/// Emits a single-line comment: `// text`
///
pub def comment(text: String): Unit \ Build =
        Build.declComment("// ${text}")

    ///
    /// Emits a block comment: `/* text */`
    ///
    pub def blockComment(text: String): Unit \ Build =
        Build.declComment("/* ${text} */")
}
