mod TestBuiltins {
    use Glsl.Expr.renderExpr
    use Glsl.Smart.glPosition
    use Glsl.Smart.glFragCoord
    use Glsl.Smart.glFrontFacing
    use Glsl.Smart.glViewIndex

    @Test
    pub def testBuiltInVertex(): Unit \ Assert = {
        let pos = glPosition();
        Assert.assertEq(expected = "gl_Position", renderExpr(pos))
    }

    @Test
    pub def testBuiltInFragmentInputs(): Unit \ Assert = {
        let coord = glFragCoord();
        let facing = glFrontFacing();
        let view = glViewIndex();

        Assert.assertEq(expected = "gl_FragCoord", renderExpr(coord));
        Assert.assertEq(expected = "gl_FrontFacing", renderExpr(facing));
        Assert.assertEq(expected = "gl_ViewIndex", renderExpr(view))
    }
}
