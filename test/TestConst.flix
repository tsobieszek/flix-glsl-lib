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

        let hasEpsilon = src#body |> Vector.exists(s ->
            String.contains({substr = "epsilon"}, Glsl.Ast.renderStmt(s) |> Vector.toList |> String.unlines));
        let hasWhite = src#body |> Vector.exists(s ->
            String.contains({substr = "white"}, Glsl.Ast.renderStmt(s) |> Vector.toList |> String.unlines));

        Assert.assertTrue(hasEpsilon);
        Assert.assertTrue(hasWhite)
    }

    @Test
    pub def testConstVar(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _n: Expr[Vec3] = constVar("N", vec3(litF(1.0f32), litF(2.0f32), litF(3.0f32)));
            ()
        });
        let found = src#body |> Vector.exists(s ->
            String.contains({substr = "N"}, Glsl.Ast.renderStmt(s) |> Vector.toList |> String.unlines));
        Assert.assertTrue(found)
    }

    @Test
    pub def testConstVarMultiple(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _x: Expr[Float32] = constVar("x", litF(0.5f32));
            let _y: Expr[Float32] = constVar("y", litF(1.5f32));
            ()
        });
        let hasX = src#body |> Vector.exists(s ->
            String.contains({substr = "x"}, Glsl.Ast.renderStmt(s) |> Vector.toList |> String.unlines));
        let hasY = src#body |> Vector.exists(s ->
            String.contains({substr = "y"}, Glsl.Ast.renderStmt(s) |> Vector.toList |> String.unlines));
        Assert.assertTrue(hasX);
        Assert.assertTrue(hasY)
    }
}
