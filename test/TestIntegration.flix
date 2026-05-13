mod TestIntegration {
    use Glsl.Build.runBuild
    use Glsl.Expr.Expr
    use Glsl.Builtin.litF
    use Glsl.Builtin.vec3
    use Glsl.Builtin.transpose
    use Glsl.Builtin.textureQueryLod
    use Glsl.Builtin.asFloat
    use Glsl.Builtin.asInt
    use Glsl.Builtin.asUint
    use Glsl.Builtin.asBool
    use Glsl.Smart.glPosition
    use Glsl.Smart.glFragCoord
    use Glsl.Smart.glFrontFacing
    use Glsl.Smart.glViewIndex
    use Glsl.Smart.constVar
    use Glsl.Smart.samplerWithLayout
    use Glsl.Smart.uniformWithSet
    use Glsl.Smart.declareUniformBlockMulti
    use Glsl.Smart.uniformBlockMemberTyped
    use Glsl.Smart.comment
    use Glsl.Smart.blockComment
    use Glsl.Types.Vec2
    use Glsl.Types.Vec3
    use Glsl.Types.Vec4
    use Glsl.Types.Mat4
    use Glsl.Types.Sampler2D

    @Test
    pub def testMediumPriorityIntegration(): Unit \ Assert = {
        let src = runBuild(_ -> {
            comment("Fragment shader with all medium-priority features");
            blockComment("Demonstrates built-ins, const vars, matrix ops, set qualifiers");

            let _mvpMat: Expr[Mat4] = uniformWithSet("mvpMatrix", 0, 0);
            let _normalMat: Expr[Mat4] = uniformWithSet("normalMatrix", 0, 1);

            declareUniformBlockMulti("ShaderParams", "params", Some(1), 0, _ -> {
                discard uniformBlockMemberTyped("lightColor", (Proxy.Proxy: Proxy[Vec3]));
                discard uniformBlockMemberTyped("aoFactor", (Proxy.Proxy: Proxy[Float32]));
                discard (uniformBlockMemberTyped("metallic", (Proxy.Proxy: Proxy[Float32])): Expr[Float32]);
                ()
            });
            ()
        });

        // Verify all sections have expected content
        let hasComments = src#body |> Vector.exists(s ->
            String.contains({substr = "//"}, Glsl.Ast.renderStmt(s) |> Vector.toList |> String.unlines));
        let hasBlockComment = src#body |> Vector.exists(s ->
            String.contains({substr = "/*"}, Glsl.Ast.renderStmt(s) |> Vector.toList |> String.unlines));
        let hasUniforms = Vector.length(src#uniforms) > 0;
        let hasSetQualifiers = src#uniforms |> Vector.exists(u ->
            String.contains({substr = "set ="}, Glsl.Ast.renderUniform(u)));
        let hasFunctions = src#topLevels |> Vector.exists(t ->
            String.contains({substr = "ShaderParams"}, Glsl.Ast.renderTopLevel(t)));
        let hasBodyStatements = src#body |> Vector.exists(s ->
            String.contains({substr = "const"}, Glsl.Ast.renderStmt(s) |> Vector.toList |> String.unlines));

        Assert.assertTrue(hasComments);
        Assert.assertTrue(hasBlockComment);
        Assert.assertTrue(hasUniforms);
        Assert.assertTrue(hasSetQualifiers);
        Assert.assertTrue(hasFunctions);
        Assert.assertTrue(hasBodyStatements)
    }
}
