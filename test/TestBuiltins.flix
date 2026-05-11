mod TestBuiltins {
    use Glsl.Expr.render
    use Glsl.Smart.glPosition
    use Glsl.Smart.glFragCoord
    use Glsl.Smart.glFrontFacing
    use Glsl.Smart.glViewIndex

    @Test
    pub def testBuiltInVertex(): Unit \ Assert = {
        let pos = glPosition();
        Assert.assertEq(expected = "gl_Position", render(pos))
    }

    @Test
    pub def testBuiltInFragmentInputs(): Unit \ Assert = {
        let coord = glFragCoord();
        let facing = glFrontFacing();
        let view = glViewIndex();

        Assert.assertEq(expected = "gl_FragCoord", render(coord));
        Assert.assertEq(expected = "gl_FrontFacing", render(facing));
        Assert.assertEq(expected = "gl_ViewIndex", render(view))
    }
}
