mod TestTextureLod {
    use Glsl.Expr.render
    use Glsl.Expr.Expr
    use Glsl.Builtin.textureQueryLod
    use Glsl.Types.Vec2
    use Glsl.Types.Sampler2D

    @Test
    pub def testTextureQueryLodFeature(): Unit \ Assert = {
        let sampler: Expr[Sampler2D] = Glsl.Expr.Var("albedoMap");
        let coord: Expr[Vec2] = Glsl.Expr.Var("uv");
        let result = textureQueryLod(sampler, coord);
        Assert.assertEq(expected = "textureQueryLod(albedoMap, uv)", render(result))
    }
}
