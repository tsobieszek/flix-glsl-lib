mod TestTypes {

    use Glsl.Build.runBuild
    use Glsl.Stage.Stage
    use Glsl.Render.renderStage
    use Glsl.Smart.uniformArray
    use Glsl.Smart.localArray
    use Glsl.Smart.uniform
    use Glsl.Smart.output
    use Glsl.Smart.assign
    use Glsl.Builtin.litF
    use Glsl.Builtin.litI
    use Glsl.Builtin.litU
    use Glsl.Builtin.litB
    use Glsl.Builtin.ivec2
    use Glsl.Builtin.ivec3
    use Glsl.Builtin.ivec4
    use Glsl.Builtin.uvec2
    use Glsl.Builtin.uvec3
    use Glsl.Builtin.uvec4
    use Glsl.Builtin.bvec2
    use Glsl.Builtin.bvec3
    use Glsl.Builtin.bvec4
    use Glsl.Builtin.anyBVec
    use Glsl.Builtin.allBVec
    use Glsl.Builtin.notBVec
    use Glsl.Builtin.index
    use Glsl.Builtin.vec4FromVec3
    use Glsl.Types.IVec2
    use Glsl.Types.IVec3
    use Glsl.Types.IVec4
    use Glsl.Types.UVec2
    use Glsl.Types.UVec3
    use Glsl.Types.UVec4
    use Glsl.Types.BVec2
    use Glsl.Types.BVec3
    use Glsl.Types.BVec4
    use Glsl.Types.Vec3
    use Glsl.Types.Vec4
    use Glsl.Types.GlslArray
    use Glsl.Expr.Expr

    @Test
    def testIntegerVectors(): Unit \ Assert = {
        Assert.assertEq(expected = "ivec2(1, 2)", Glsl.Expr.render(ivec2(litI(1), litI(2))));
        Assert.assertEq(expected = "ivec3(3, 3, 3)", Glsl.Expr.render(ivec3(litI(3), litI(3), litI(3))));
        Assert.assertEq(expected = "ivec4(4, 5, 6, 7)", Glsl.Expr.render(ivec4(litI(4), litI(5), litI(6), litI(7))))
    }

    @Test
    def testUnsignedVectorsUseUSuffix(): Unit \ Assert = {
        Assert.assertEq(expected = "uvec2(1u, 2u)", Glsl.Expr.render(uvec2(litU(1), litU(2))));
        Assert.assertEq(expected = "uvec3(3u, 3u, 3u)", Glsl.Expr.render(uvec3(litU(3), litU(3), litU(3))));
        Assert.assertEq(expected = "uvec4(4u, 5u, 6u, 7u)", Glsl.Expr.render(uvec4(litU(4), litU(5), litU(6), litU(7))))
    }

    @Test
    def testBoolVectors(): Unit \ Assert = {
        Assert.assertEq(expected = "bvec2(true, false)", Glsl.Expr.render(bvec2(litB(true), litB(false))));
        Assert.assertEq(expected = "bvec3(true, true, true)", Glsl.Expr.render(bvec3(litB(true), litB(true), litB(true))));
        Assert.assertEq(expected = "bvec4(true, false, true, false)", Glsl.Expr.render(bvec4(litB(true), litB(false), litB(true), litB(false))));
        Assert.assertEq(expected = "any(bvec2(true, false))", Glsl.Expr.render(anyBVec(bvec2(litB(true), litB(false)))));
        Assert.assertEq(expected = "all(bvec3(true, true, true))", Glsl.Expr.render(allBVec(bvec3(litB(true), litB(true), litB(true)))));
        Assert.assertEq(expected = "not(bvec4(true, false, true, false))", Glsl.Expr.render(notBVec(bvec4(litB(true), litB(false), litB(true), litB(false)))))
    }

    @Test
    def testIntegerVectorUniformDeclaration(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let coord: Expr[IVec3] = uniform("coord");
            let color: Expr[Vec4] = output(0, "fragColor");
            assign(color, vec4FromVec3(vec3FromIVec3(coord), litF(1.0f32)))
        });
        let glsl = renderStage(Stage.Fragment, src);
        Assert.assertEq(expected = true, String.contains({substr = "uniform ivec3 coord;"}, glsl))
    }

    @Test
    def testBoolVectorLocal(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let mask: Expr[BVec3] = bvec3(litB(true), litB(false), litB(true));
            let color: Expr[Vec4] = output(0, "fragColor");
            let _: Expr[Bool] = anyBVec(mask);
            assign(color, vec4FromVec3(Glsl.Builtin.vec3(litF(0.0f32), litF(0.0f32), litF(0.0f32)), litF(1.0f32)))
        });
        let glsl = renderStage(Stage.Fragment, src);
        Assert.assertEq(expected = true, String.contains({substr = "fragColor = vec4(vec3(0.0, 0.0, 0.0), 1.0);"}, glsl))
    }

    @Test
    def testArrayIndexing(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let weights: Expr[GlslArray[Vec3]] = uniformArray("weights", 4);
            let color: Expr[Vec4] = output(0, "fragColor");
            assign(color, vec4FromVec3(index(weights, litI(2)), litF(1.0f32)))
        });
        let glsl = renderStage(Stage.Fragment, src);
        Assert.assertEq(expected = true, String.contains({substr = "uniform vec3 weights[4];"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "fragColor = vec4(weights[2], 1.0);"}, glsl))
    }

    @Test
    def testLocalArrayDeclaration(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _samples: Expr[GlslArray[Vec3]] = localArray("samples", 8);
            let color: Expr[Vec4] = output(0, "fragColor");
            assign(color, Glsl.Builtin.vec4(litF(0.0f32), litF(0.0f32), litF(0.0f32), litF(1.0f32)))
        });
        let glsl = renderStage(Stage.Fragment, src);
        Assert.assertEq(expected = true, String.contains({substr = "vec3 samples[8];"}, glsl))
    }

    /// Stub used by `testIntegerVectorUniformDeclaration` — coerces an
    /// `Expr[IVec3]` to `Expr[Vec3]` for the rendered GLSL fragment. This
    /// is the kind of explicit cast that integer-vector code paths need;
    /// it lives in the test for now since the production helpers do not
    /// yet expose conversion functions.
    def vec3FromIVec3(x: Expr[IVec3]): Expr[Vec3] =
        Expr.App("vec3", List#{Glsl.Expr.boxed(x)})
}
