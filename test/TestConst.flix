mod TestConst {
    use Glsl.Build.runBuild
    use Glsl.Expr.Expr
    use Glsl.Builtin.litF
    use Glsl.Builtin.vec3
    use Glsl.Smart.constVar
    use Glsl.Types.Vec3

    @Test
    pub def testConstLocalVariables(): Unit \ Assert = {
        let src = runBuild(_ -> {
            discard (constVar("epsilon", litF(0.001f32)): Expr[Float32]);
            discard (constVar("white", vec3(litF(1.0f32), litF(1.0f32), litF(1.0f32))): Expr[Vec3]);
            ()
        });

        let hasEpsilon = src#body |> Vector.exists(line -> 
            String.contains({substr = "const float epsilon = 0.001;"}, line));
        let hasWhite = src#body |> Vector.exists(line -> 
            String.contains({substr = "const vec3 white"}, line));

        Assert.assertTrue(hasEpsilon);
        Assert.assertTrue(hasWhite)
    }

    @Test
    pub def testConstVar(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _n: Expr[Vec3] = constVar("N", vec3(litF(1.0f32), litF(2.0f32), litF(3.0f32)));
            ()
        });
        let found = src#body |> Vector.exists(line ->
            String.contains({substr = "const vec3 N = vec3(1.0, 2.0, 3.0);"}, line)
        );
        Assert.assertTrue(found)
    }

    @Test
    pub def testConstVarMultiple(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _x: Expr[Float32] = constVar("x", litF(0.5f32));
            let _y: Expr[Float32] = constVar("y", litF(1.5f32));
            ()
        });
        let hasX = src#body |> Vector.exists(line -> String.contains({substr = "const float x = 0.5;"}, line));
        let hasY = src#body |> Vector.exists(line -> String.contains({substr = "const float y = 1.5;"}, line));
        Assert.assertTrue(hasX);
        Assert.assertTrue(hasY)
    }
}
