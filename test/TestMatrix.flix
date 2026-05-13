mod TestMatrix {
    use Glsl.Expr.renderExpr
    use Glsl.Expr.Expr
    use Glsl.Builtin.litF
    use Glsl.Builtin.vec3
    use Glsl.Builtin.transpose
    use Glsl.Builtin.inverse
    use Glsl.Builtin.outerProduct
    use Glsl.Types.Vec3
    use Glsl.Types.Mat4

    @Test
    pub def testMatrixOperations(): Unit \ Assert = {
        let m: Expr[Mat4] = Expr.Of(Glsl.Expr.Ast.Var("M"));
        let v1: Expr[Vec3] = vec3(litF(1.0f32), litF(0.0f32), litF(0.0f32));
        let v2: Expr[Vec3] = vec3(litF(0.0f32), litF(1.0f32), litF(0.0f32));

        Assert.assertEq(expected = "transpose(M)", renderExpr(transpose(m)));
        Assert.assertEq(expected = "inverse(M)", renderExpr(inverse(m)));
        Assert.assertEq(expected = "outerProduct(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0))", 
            renderExpr(outerProduct(v1, v2)))
    }
}
