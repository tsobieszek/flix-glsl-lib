mod TestAdvancedQualifiers {
    use Glsl.Build.runBuild
    use Glsl.Expr.Expr
    use Glsl.Smart.uniformWithBinding
    use Glsl.Smart.declareUniformBlockMember
    use Glsl.Smart.uniformWithPrecision
    use Glsl.Smart.uniformWithLayoutAndPrecision

    @Test
    def testBindingLayoutQualifier(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _u: Expr[Float32] = uniformWithBinding("myUniform", 0);
            ()
        });
        let found = src#uniforms |> Vector.exists(u ->
            String.contains({substr = "layout(binding = 0)"}, Glsl.Ast.renderUniform(u)));
        Assert.assertTrue(found)
    }

    @Test
    def testMultipleBindings(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _u1: Expr[Float32] = uniformWithBinding("u1", 0);
            let _u2: Expr[Float32] = uniformWithBinding("u2", 1);
            ()
        });
        let hasBinding0 = src#uniforms |> Vector.exists(u ->
            String.contains({substr = "layout(binding = 0)"}, Glsl.Ast.renderUniform(u)));
        let hasBinding1 = src#uniforms |> Vector.exists(u ->
            String.contains({substr = "layout(binding = 1)"}, Glsl.Ast.renderUniform(u)));
        Assert.assertTrue(hasBinding0 and hasBinding1)
    }

    @Test
    def testUniformBlockDeclaration(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _u: Expr[Float32] = declareUniformBlockMember("MyBlock", "value", 0);
            ()
        });
        let hasBlock = src#topLevels |> Vector.exists(t ->
            String.contains({substr = "uniform MyBlock"}, Glsl.Ast.renderTopLevel(t)));
        Assert.assertTrue(hasBlock)
    }

    @Test
    def testUniformBlockMemberType(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _u: Expr[Float32] = declareUniformBlockMember("MyBlock", "floatMember", 0);
            ()
        });
        let hasMember = src#topLevels |> Vector.exists(t ->
            String.contains({substr = "float floatMember;"}, Glsl.Ast.renderTopLevel(t)));
        Assert.assertTrue(hasMember)
    }

    @Test
    def testPrecisionQualifier(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _u: Expr[Float32] = uniformWithPrecision("myFloat", "mediump");
            ()
        });
        let found = src#uniforms |> Vector.exists(u ->
            String.contains({substr = "mediump"}, Glsl.Ast.renderUniform(u)));
        Assert.assertTrue(found)
    }

    @Test
    def testBindingAndPrecision(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _u: Expr[Float32] = uniformWithLayoutAndPrecision("myFloat", Some(0), Some("highp"));
            ()
        });
        let found = src#uniforms |> Vector.exists(u ->
            let rendered = Glsl.Ast.renderUniform(u);
            String.contains({substr = "binding = 0"}, rendered) and String.contains({substr = "highp"}, rendered));
        Assert.assertTrue(found)
    }

    @Test
    def testNoBindingNoLayoutQualifier(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _u: Expr[Float32] = uniformWithLayoutAndPrecision("plain", None, None);
            ()
        });
        let found = src#uniforms |> Vector.exists(u ->
            String.startsWith({prefix = "uniform float plain"}, Glsl.Ast.renderUniform(u)));
        Assert.assertTrue(found)
    }
}
