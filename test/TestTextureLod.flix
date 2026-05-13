mod TestTextureLod {
    use Glsl.Expr.renderExpr
    use Glsl.Expr.Expr
    use Glsl.Builtin.textureQueryLod
    use Glsl.Types.Vec2
    use Glsl.Types.Sampler2D

    @Test
    pub def testTextureQueryLodFeature(): Unit \ Assert = {
        let sampler: Expr[Sampler2D] = Expr.Of(Glsl.Expr.Ast.Var("albedoMap"));
        let coord: Expr[Vec2] = Expr.Of(Glsl.Expr.Ast.Var("uv"));
        let result = textureQueryLod(sampler, coord);
        Assert.assertEq(expected = "textureQueryLod(albedoMap, uv)", renderExpr(result))
    }
}
