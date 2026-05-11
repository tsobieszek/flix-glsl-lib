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
                discard (uniformBlockMemberTyped("metallic", (Proxy.Proxy: Proxy[Float32])): Expr[Float32])
            });

            let _albedo: Expr[Sampler2D] = samplerWithLayout("albedoSampler", 2, 0);
            let _normal: Expr[Sampler2D] = samplerWithLayout("normalSampler", 2, 1);

            let _fragCoord: Expr[Vec4] = glFragCoord();
            let _frontFace: Expr[Bool] = glFrontFacing();
            let _viewIdx: Expr[Glsl.Types.UInt32] = glViewIndex();
            let _outPos: Expr[Vec4] = glPosition();

            let _ambientLight: Expr[Vec3] = constVar("ambientLight", 
                vec3(litF(0.2f32), litF(0.2f32), litF(0.2f32)));
            let _pi: Expr[Float32] = constVar("PI", litF(3.14159f32));

            let _transNormal: Expr[Mat4] = constVar("transNormal", 
                transpose(Glsl.Expr.Var("normalMatrix")));

            let _lodQuery: Expr[Vec2] = textureQueryLod(
                Glsl.Expr.Var("albedoSampler"),
                Glsl.Expr.Var("texCoord")
            );

            let _asUintVal: Expr[Int32] = asUint(litF(255.99f32));
            let _asIntVal: Expr[Int32] = asInt(litF(42.5f32));
            let _asFloatVal: Expr[Float32] = asFloat(Glsl.Expr.Var("someInt"));
            let _asBoolVal: Expr[Bool] = asBool(litF(1.0f32));

            comment("All medium-priority features demonstrated successfully")
        });

        // Verify all sections have expected content
        let hasComments = src#body |> Vector.exists(line -> String.contains({substr = "//"}, line));
        let hasBlockComment = src#body |> Vector.exists(line -> String.contains({substr = "/*"}, line));
        let hasUniforms = src#uniforms |> Vector.exists(line -> String.contains({substr = "uniform"}, line));
        let hasSetQualifiers = src#uniforms |> Vector.exists(line -> String.contains({substr = "set ="}, line));
        let hasFunctions = src#functions |> Vector.exists(line -> String.contains({substr = "ShaderParams"}, line));
        let hasBodyStatements = src#body |> Vector.exists(line -> String.contains({substr = "const"}, line));

        Assert.assertTrue(hasComments);
        Assert.assertTrue(hasBlockComment);
        Assert.assertTrue(hasUniforms);
        Assert.assertTrue(hasSetQualifiers);
        Assert.assertTrue(hasFunctions);
        Assert.assertTrue(hasBodyStatements)
    }
}
