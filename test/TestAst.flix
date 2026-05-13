use Glsl.Types.{TypeRef, Precision}
use Glsl.Ast.{Preprocessor, BlockMember, FunctionParam, ForInit, Uniform, Attribute, Varying, Output, Global, TopLevel, Stmt, Layout, VaryingDirection, ParamQualifier, LayoutItem}
use Glsl.Expr.{Ast}

@Test
def testRenderLayoutEmpty(): Unit \ Assert =
    let layout: Layout = Vector#{};
    let rendered = Glsl.Ast.renderLayout(layout);
    Assert.assertEq(expected = "", rendered)

@Test
def testRenderLayoutBinding(): Unit \ Assert =
    let layout: Layout = Vector#{LayoutItem.Binding(1)};
    let rendered = Glsl.Ast.renderLayout(layout);
    Assert.assertEq(expected = "layout(binding = 1) ", rendered)

@Test
def testRenderLayoutSet(): Unit \ Assert =
    let layout: Layout = Vector#{LayoutItem.Set(2)};
    let rendered = Glsl.Ast.renderLayout(layout);
    Assert.assertEq(expected = "layout(set = 2) ", rendered)

@Test
def testRenderLayoutLocation(): Unit \ Assert =
    let layout: Layout = Vector#{LayoutItem.Location(0)};
    let rendered = Glsl.Ast.renderLayout(layout);
    Assert.assertEq(expected = "layout(location = 0) ", rendered)

@Test
def testRenderLayoutMultiple(): Unit \ Assert =
    let layout: Layout = Vector#{LayoutItem.Std140, LayoutItem.Binding(1)};
    let rendered = Glsl.Ast.renderLayout(layout);
    Assert.assertEq(expected = "layout(std140, binding = 1) ", rendered)

@Test
def testRenderPreprocessorDefine(): Unit \ Assert =
    let p = Preprocessor.Define("PI", "3.14159");
    let rendered = Glsl.Ast.renderPreprocessor(p);
    Assert.assertEq(expected = "#define PI 3.14159", rendered)

@Test
def testRenderPreprocessorDefineFn(): Unit \ Assert =
    let p = Preprocessor.DefineFn("MAX", Vector#{"a","b"}, "((a)>(b)?(a):(b))");
    let rendered = Glsl.Ast.renderPreprocessor(p);
    Assert.assertEq(expected = "#define MAX(a,b) ((a)>(b)?(a):(b))", rendered)

@Test
def testRenderPreprocessorExtension(): Unit \ Assert =
    let p = Preprocessor.Extension("GL_ARB_separate_shader_objects", "enable");
    let rendered = Glsl.Ast.renderPreprocessor(p);
    Assert.assertEq(expected = "#extension GL_ARB_separate_shader_objects : enable", rendered)

@Test
def testRenderPreprocessorInclude(): Unit \ Assert =
    let p = Preprocessor.Include("common.glsl");
    let rendered = Glsl.Ast.renderPreprocessor(p);
    Assert.assertEq(expected = "#include \"common.glsl\"", rendered)

@Test
def testRenderBlockMember(): Unit \ Assert =
    let m = BlockMember.Member(TypeRef.Vec3, "pos");
    let rendered = Glsl.Ast.renderBlockMember(m);
    Assert.assertEq(expected = "vec3 pos;", rendered)

@Test
def testRenderBlockMemberLineComment(): Unit \ Assert =
    let m = BlockMember.MemberLineComment("position of light");
    let rendered = Glsl.Ast.renderBlockMember(m);
    Assert.assertEq(expected = "// position of light", rendered)

@Test
def testRenderFunctionParamPlain(): Unit \ Assert =
    let p = FunctionParam.Param(ParamQualifier.Plain, TypeRef.Float, "x");
    let rendered = Glsl.Ast.renderFunctionParam(p);
    Assert.assertEq(expected = "float x", rendered)

@Test
def testRenderFunctionParamInout(): Unit \ Assert =
    let p = FunctionParam.Param(ParamQualifier.Inout, TypeRef.Vec3, "color");
    let rendered = Glsl.Ast.renderFunctionParam(p);
    Assert.assertEq(expected = "inout vec3 color", rendered)

@Test
def testRenderFunctionParamConst(): Unit \ Assert =
    let p = FunctionParam.Param(ParamQualifier.Const, TypeRef.Vec4, "pos");
    let rendered = Glsl.Ast.renderFunctionParam(p);
    Assert.assertEq(expected = "const vec4 pos", rendered)

@Test
def testRenderForInitDecl(): Unit \ Assert =
    let init = ForInit.ForInitDecl(TypeRef.Int, "i", Ast.Lit("0"));
    let rendered = Glsl.Ast.renderForInit(init);
    Assert.assertEq(expected = "int i = 0", rendered)

@Test
def testRenderForInitExpr(): Unit \ Assert =
    let init = ForInit.ForInitExpr(Ast.Var("i"));
    let rendered = Glsl.Ast.renderForInit(init);
    Assert.assertEq(expected = "i", rendered)

@Test
def testRenderForInitNone(): Unit \ Assert =
    let init = ForInit.ForInitNone;
    let rendered = Glsl.Ast.renderForInit(init);
    Assert.assertEq(expected = "", rendered)

@Test
def testRenderUniformBasic(): Unit \ Assert =
    let u = Uniform.U(TypeRef.Mat4, "mvp", Vector#{}, None);
    let rendered = Glsl.Ast.renderUniform(u);
    Assert.assertEq(expected = "uniform mat4 mvp;", rendered)

@Test
def testRenderUniformWithBinding(): Unit \ Assert =
    let u = Uniform.U(TypeRef.Float, "x", Vector#{LayoutItem.Binding(1)}, None);
    let rendered = Glsl.Ast.renderUniform(u);
    Assert.assertEq(expected = "layout(binding = 1) uniform float x;", rendered)

@Test
def testRenderUniformWithPrecision(): Unit \ Assert =
    let u = Uniform.U(TypeRef.Float, "y", Vector#{}, Some(Precision.Highp));
    let rendered = Glsl.Ast.renderUniform(u);
    Assert.assertEq(expected = "uniform highp float y;", rendered)

@Test
def testRenderUniformWithLayoutAndPrecision(): Unit \ Assert =
    let u = Uniform.U(TypeRef.Float, "z", Vector#{LayoutItem.Binding(2)}, Some(Precision.Mediump));
    let rendered = Glsl.Ast.renderUniform(u);
    Assert.assertEq(expected = "layout(binding = 2) uniform mediump float z;", rendered)

@Test
def testRenderAttribute(): Unit \ Assert =
    let a = Attribute.A(0, TypeRef.Vec3, "position");
    let rendered = Glsl.Ast.renderAttribute(a);
    Assert.assertEq(expected = "layout(location = 0) in vec3 position;", rendered)

@Test
def testRenderVaryingIn(): Unit \ Assert =
    let v = Varying.V(VaryingDirection.In, TypeRef.Vec3, "fragPos");
    let rendered = Glsl.Ast.renderVarying(v);
    Assert.assertEq(expected = "in vec3 fragPos;", rendered)

@Test
def testRenderVaryingOut(): Unit \ Assert =
    let v = Varying.V(VaryingDirection.Out, TypeRef.Vec4, "color");
    let rendered = Glsl.Ast.renderVarying(v);
    Assert.assertEq(expected = "out vec4 color;", rendered)

@Test
def testRenderOutput(): Unit \ Assert =
    let o = Output.O(0, TypeRef.Vec4, "fragColor");
    let rendered = Glsl.Ast.renderOutput(o);
    Assert.assertEq(expected = "layout(location = 0) out vec4 fragColor;", rendered)

@Test
def testRenderGlobal(): Unit \ Assert =
    let g = Global.G(TypeRef.Float, "globalTime", Ast.Lit("0.0"));
    let rendered = Glsl.Ast.renderGlobal(g);
    Assert.assertEq(expected = "float globalTime = 0.0;", rendered)

@Test
def testRenderStructEmpty(): Unit \ Assert =
    let t = TopLevel.Struct("Empty", Vector#{});
    let rendered = Glsl.Ast.renderTopLevel(t);
    let expected = "struct Empty {\n\n}";
    Assert.assertEq(expected = expected, rendered)

@Test
def testRenderStmtAssign(): Unit \ Assert =
    let s = Stmt.Assign(Ast.Var("x"), Ast.Lit("1.0"));
    let rendered = Glsl.Ast.renderStmt(s);
    Assert.assertEq(expected = Vector#{"x = 1.0;"}, rendered)

@Test
def testRenderStmtAssignField(): Unit \ Assert =
    let s = Stmt.AssignField(Ast.Var("v"), "x", Ast.Lit("2.0"));
    let rendered = Glsl.Ast.renderStmt(s);
    Assert.assertEq(expected = Vector#{"v.x = 2.0;"}, rendered)

@Test
def testRenderStmtLocal(): Unit \ Assert =
    let s = Stmt.Local(TypeRef.Float, "x", Ast.Lit("3.0"));
    let rendered = Glsl.Ast.renderStmt(s);
    Assert.assertEq(expected = Vector#{"float x = 3.0;"}, rendered)

@Test
def testRenderStmtConst(): Unit \ Assert =
    let s = Stmt.Const(TypeRef.Float, "eps", Ast.Lit("0.001"));
    let rendered = Glsl.Ast.renderStmt(s);
    Assert.assertEq(expected = Vector#{"const float eps = 0.001;"}, rendered)

@Test
def testRenderStmtLocalArray(): Unit \ Assert =
    let s = Stmt.LocalArray(TypeRef.Vec3, "vertices", 10);
    let rendered = Glsl.Ast.renderStmt(s);
    Assert.assertEq(expected = Vector#{"vec3 vertices[10];"}, rendered)

@Test
def testRenderStmtBreak(): Unit \ Assert =
    let s = Stmt.Break;
    let rendered = Glsl.Ast.renderStmt(s);
    Assert.assertEq(expected = Vector#{"break;"}, rendered)

@Test
def testRenderStmtContinue(): Unit \ Assert =
    let s = Stmt.Continue;
    let rendered = Glsl.Ast.renderStmt(s);
    Assert.assertEq(expected = Vector#{"continue;"}, rendered)

@Test
def testRenderStmtReturn(): Unit \ Assert =
    let s = Stmt.Return;
    let rendered = Glsl.Ast.renderStmt(s);
    Assert.assertEq(expected = Vector#{"return;"}, rendered)

@Test
def testRenderStmtReturnExpr(): Unit \ Assert =
    let s = Stmt.ReturnExpr(Ast.Lit("1.0"));
    let rendered = Glsl.Ast.renderStmt(s);
    Assert.assertEq(expected = Vector#{"return 1.0;"}, rendered)

@Test
def testRenderStmtDiscard(): Unit \ Assert =
    let s = Stmt.Discard;
    let rendered = Glsl.Ast.renderStmt(s);
    Assert.assertEq(expected = Vector#{"discard;"}, rendered)

@Test
def testRenderStmtLineComment(): Unit \ Assert =
    let s = Stmt.LineComment("this is a comment");
    let rendered = Glsl.Ast.renderStmt(s);
    Assert.assertEq(expected = Vector#{"// this is a comment"}, rendered)

@Test
def testRenderStmtBlockComment(): Unit \ Assert =
    let s = Stmt.BlockComment("block comment");
    let rendered = Glsl.Ast.renderStmt(s);
    Assert.assertEq(expected = Vector#{"/* block comment */"}, rendered)
