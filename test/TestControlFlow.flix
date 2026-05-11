mod TestControlFlow {
    use Glsl.Build.runBuild
    use Glsl.Build.Build
    use Glsl.Stage.Stage
    use Glsl.Render.renderStage
    use Glsl.Smart.output
    use Glsl.Smart.ifStmt
    use Glsl.Smart.elseStmt
    use Glsl.Smart.elseIfStmt
    use Glsl.Smart.discardFrag
    use Glsl.Smart.assign
    use Glsl.Builtin.litF
    use Glsl.Builtin.litB
    use Glsl.Builtin.vec4
    use Glsl.Builtin.lt
    use Glsl.Builtin.andB
    use Glsl.Builtin.orB
    use Glsl.Builtin.notB
    use Glsl.Types.Vec4

    def shaderBody(): Unit \ Build = {
        let fragColor: Glsl.Expr.Expr[Vec4] = output(0, "fragColor");
        let threshold = litF(0.5f32);
        ifStmt(lt(litF(0.1f32), threshold), () -> {
            assign(fragColor, vec4(litF(1.0f32), litF(0.0f32), litF(0.0f32), litF(1.0f32)))
        });
        elseStmt(() -> {
            discardFrag()
        })
    }

    def complexShaderBody(): Unit \ Build = {
        let fragColor: Glsl.Expr.Expr[Vec4] = output(0, "fragColor");
        let b1 = litB(true);
        let b2 = litB(false);
        ifStmt(andB(b1, b2), () -> {
            assign(fragColor, vec4(litF(1.0f32), litF(1.0f32), litF(1.0f32), litF(1.0f32)))
        });
        elseIfStmt(orB(b1, notB(b2)), () -> {
            assign(fragColor, vec4(litF(0.0f32), litF(0.0f32), litF(0.0f32), litF(1.0f32)))
        });
        elseStmt(() -> {
            discardFrag()
        })
    }

    @Test
    def testComplexControlFlow(): Unit \ Assert = {
        let src = runBuild(_ -> complexShaderBody());
        let glsl = renderStage(Stage.Fragment, src);
        Assert.assertEq(expected = true, String.contains({substr = "if ((true && false)) {"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "else if ((true || (!false))) {"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "else {"}, glsl))
    }

    @Test
    def testIfElseEmit(): Unit \ Assert = {
        let src = runBuild(_ -> shaderBody());
        let glsl = renderStage(Stage.Fragment, src);
        Assert.assertEq(expected = true, String.contains({substr = "if ((0.1 < 0.5)) {"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "fragColor = vec4(1.0, 0.0, 0.0, 1.0);"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "else {"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "discard;"}, glsl))
    }
}
