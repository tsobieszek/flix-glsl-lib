mod TestTexture {

    use Glsl.Build.runBuild
    use Glsl.Stage.Stage
    use Glsl.Render.renderStage
    use Glsl.Smart.uniform
    use Glsl.Smart.varying
    use Glsl.Smart.output
    use Glsl.Smart.assign
    use Glsl.Smart.samplerWithLayout
    use Glsl.Builtin.texture
    use Glsl.Builtin.vec2
    use Glsl.Builtin.litF
    use Glsl.Types.Vec2
    use Glsl.Types.Vec4
    use Glsl.Types.Sampler2D
    use Glsl.Expr.Expr

    @Test
    def testTextureSampling(): Unit \ Assert = {
        let frag = runBuild(_ -> {
            let s: Expr[Sampler2D] = uniform("uTexture");
            let uv: Expr[Vec2] = varying("in", "vTexCoord");
            let color: Expr[Vec4] = output(0, "fragColor");
            assign(color, texture(s, uv));
            ()
        });
        let glsl = renderStage(Stage.Fragment, frag);
        Assert.assertEq(expected = true, String.contains({substr = "uniform sampler2D uTexture;"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "in vec2 vTexCoord;"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "fragColor = texture(uTexture, vTexCoord);"}, glsl))
    }

    @Test
    def testTextureSamplingWithVec2Lit(): Unit \ Assert = {
        let frag = runBuild(_ -> {
            let s: Expr[Sampler2D] = uniform("uTexture");
            let color: Expr[Vec4] = output(0, "fragColor");
            assign(color, texture(s, vec2(litF(0.5f32), litF(0.5f32))));
            ()
        });
        let glsl = renderStage(Stage.Fragment, frag);
        Assert.assertEq(expected = true, String.contains({substr = "fragColor = texture(uTexture, vec2(0.5, 0.5));"}, glsl))
    }

    @Test
    pub def testSamplerWithLayout(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _sampler: Expr[Sampler2D] = samplerWithLayout("albedoMap", 0, 1);
            ()
        });
        let found = src#uniforms |> Vector.exists(u ->
            String.contains({substr = "layout(set = 0, binding = 1) uniform sampler2D albedoMap;"}, Glsl.Ast.renderUniform(u)));
        Assert.assertTrue(found)
    }
}
