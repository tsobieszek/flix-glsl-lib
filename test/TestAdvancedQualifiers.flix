@Test
def testBindingLayoutQualifier(): Unit \ Assert =
    let src = Glsl.Build.runBuild(_ -> {
        let _u: Glsl.Expr.Expr[Float32] = Glsl.Smart.uniformWithBinding("myUniform", 0);
        ()
    });
    let found = src#uniforms |> Vector.exists(line ->
        String.startsWith({prefix = "layout(binding = 0)"}, line)
    );
    Assert.assertTrue(found)

@Test
def testMultipleBindings(): Unit \ Assert =
    let src = Glsl.Build.runBuild(_ -> {
        let _u1: Glsl.Expr.Expr[Float32] = Glsl.Smart.uniformWithBinding("u1", 0);
        let _u2: Glsl.Expr.Expr[Float32] = Glsl.Smart.uniformWithBinding("u2", 1);
        ()
    });
    let hasBinding0 = src#uniforms |> Vector.exists(line ->
        String.startsWith({prefix = "layout(binding = 0)"}, line)
    );
    let hasBinding1 = src#uniforms |> Vector.exists(line ->
        String.startsWith({prefix = "layout(binding = 1)"}, line)
    );
    Assert.assertTrue(hasBinding0 and hasBinding1)

@Test
def testUniformBlockDeclaration(): Unit \ Assert =
    let src = Glsl.Build.runBuild(_ -> {
        let _u: Glsl.Expr.Expr[Float32] = Glsl.Smart.declareUniformBlockMember("MyBlock", "value", 0);
        ()
    });
    let hasBlock = src#functions |> Vector.exists(line ->
        String.contains({substr = "uniform MyBlock"}, line)
    );
    Assert.assertTrue(hasBlock)

@Test
def testUniformBlockMemberType(): Unit \ Assert =
    let src = Glsl.Build.runBuild(_ -> {
        let _u: Glsl.Expr.Expr[Float32] = Glsl.Smart.declareUniformBlockMember("MyBlock", "floatMember", 0);
        ()
    });
    let hasMember = src#functions |> Vector.exists(line ->
        String.contains({substr = "float floatMember;"}, line)
    );
    Assert.assertTrue(hasMember)

@Test
def testPrecisionQualifier(): Unit \ Assert =
    let src = Glsl.Build.runBuild(_ -> {
        let _u: Glsl.Expr.Expr[Float32] = Glsl.Smart.uniformWithPrecision("myFloat", "mediump");
        ()
    });
    let found = src#uniforms |> Vector.exists(line ->
        String.contains({substr = "mediump"}, line)
    );
    Assert.assertTrue(found)

@Test
def testBindingAndPrecision(): Unit \ Assert =
    let src = Glsl.Build.runBuild(_ -> {
        let _u: Glsl.Expr.Expr[Float32] = Glsl.Smart.uniformWithLayoutAndPrecision("myFloat", Some(0), Some("highp"));
        ()
    });
    let found = src#uniforms |> Vector.exists(line ->
        String.contains({substr = "binding = 0"}, line) and String.contains({substr = "highp"}, line)
    );
    Assert.assertTrue(found)

@Test
def testNoBindingNoLayoutQualifier(): Unit \ Assert =
    let src = Glsl.Build.runBuild(_ -> {
        let _u: Glsl.Expr.Expr[Float32] = Glsl.Smart.uniformWithLayoutAndPrecision("plain", None, None);
        ()
    });
    let found = src#uniforms |> Vector.exists(line ->
        String.startsWith({prefix = "uniform float plain"}, line)
    );
    Assert.assertTrue(found)
