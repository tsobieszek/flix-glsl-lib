mod TestVulkan {
    use Glsl.Build.runBuild
    use Glsl.Expr.Expr
    use Glsl.Smart.samplerWithLayout
    use Glsl.Smart.uniformWithSet
    use Glsl.Types.Vec4
    use Glsl.Types.Sampler2D

    @Test
    pub def testVulkanSetQualifiers(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _: Expr[Sampler2D] = samplerWithLayout("tex0", 0, 0);
            let _: Expr[Sampler2D] = samplerWithLayout("tex1", 0, 1);
            let _: Expr[Vec4] = uniformWithSet("data0", 1, 0);
            let _: Expr[Vec4] = uniformWithSet("data1", 1, 1);
            ()
        });

        let s1Present = src#uniforms |> Vector.exists(u ->
            String.contains({substr = "set = 0, binding = 0"}, Glsl.Ast.renderUniform(u)));
        let s2Present = src#uniforms |> Vector.exists(u ->
            String.contains({substr = "set = 0, binding = 1"}, Glsl.Ast.renderUniform(u)));
        let u1Present = src#uniforms |> Vector.exists(u ->
            String.contains({substr = "set = 1, binding = 0"}, Glsl.Ast.renderUniform(u)));
        let u2Present = src#uniforms |> Vector.exists(u ->
            String.contains({substr = "set = 1, binding = 1"}, Glsl.Ast.renderUniform(u)));

        Assert.assertTrue(s1Present);
        Assert.assertTrue(s2Present);
        Assert.assertTrue(u1Present);
        Assert.assertTrue(u2Present)
    }
}
