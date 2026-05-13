mod TestUniformBlocks {
    use Glsl.Build.runBuild
    use Glsl.Smart.declareUniformBlockMulti
    use Glsl.Smart.uniformBlockMemberTyped
    use Glsl.Smart.uniformWithSet
    use Glsl.Smart.samplerWithLayout
    use Glsl.Types.Vec4
    use Glsl.Types.Sampler2D
    use Glsl.Expr.Expr

    @Test
    pub def testMultiMemberUniformBlocks(): Unit \ Assert = {
        let srcWithSet = runBuild(_ -> {
            declareUniformBlockMulti("LightData", "lights", Some(2), 3, _ -> {
                discard uniformBlockMemberTyped("position", (Proxy.Proxy: Proxy[Vec4]));
                discard uniformBlockMemberTyped("color", (Proxy.Proxy: Proxy[Vec4]));
                discard (uniformBlockMemberTyped("intensity", (Proxy.Proxy: Proxy[Float32])): Glsl.Expr.Expr[Float32]);
                ()
            });
            ()
        });

        let srcNoSet = runBuild(_ -> {
            declareUniformBlockMulti("FrameData", "frame", None, 1, _ -> {
                discard uniformBlockMemberTyped("deltaTime", (Proxy.Proxy: Proxy[Float32]));
                discard (uniformBlockMemberTyped("elapsedTime", (Proxy.Proxy: Proxy[Float32])): Glsl.Expr.Expr[Float32]);
                ()
            });
            ()
        });

        let hasSetVersion = srcWithSet#topLevels |> Vector.exists(t ->
            String.contains({substr = "layout(std140, set = 2, binding = 3) uniform LightData"}, Glsl.Ast.renderTopLevel(t)));

        let hasNoSetVersion = srcNoSet#topLevels |> Vector.exists(t ->
            String.contains({substr = "layout(std140, binding = 1) uniform FrameData"}, Glsl.Ast.renderTopLevel(t)));

        Assert.assertTrue(hasSetVersion);
        Assert.assertTrue(hasNoSetVersion)
    }

    @Test
    pub def testUniformWithSet(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _color: Expr[Vec4] = uniformWithSet("objectColor", 2, 3);
            ()
        });
        let found = src#uniforms |> Vector.exists(u ->
            String.contains({substr = "layout(set = 2, binding = 3) uniform vec4 objectColor;"}, Glsl.Ast.renderUniform(u)));
        Assert.assertTrue(found)
    }

    @Test
    pub def testMultipleUniformsWithSet(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _samp1: Expr[Sampler2D] = samplerWithLayout("sampler1", 0, 0);
            let _samp2: Expr[Sampler2D] = samplerWithLayout("sampler2", 0, 1);
            let _uni: Expr[Vec4] = uniformWithSet("data", 1, 0);
            ()
        });
        let hasSamp1 = src#uniforms |> Vector.exists(u -> String.contains({substr = "set = 0, binding = 0"}, Glsl.Ast.renderUniform(u)));
        let hasSamp2 = src#uniforms |> Vector.exists(u -> String.contains({substr = "set = 0, binding = 1"}, Glsl.Ast.renderUniform(u)));
        let hasData = src#uniforms |> Vector.exists(u -> String.contains({substr = "set = 1, binding = 0"}, Glsl.Ast.renderUniform(u)));
        Assert.assertTrue(hasSamp1);
        Assert.assertTrue(hasSamp2);
        Assert.assertTrue(hasData)
    }
}
