mod TestDirectives {

    use Glsl.Build.runBuild
    use Glsl.Stage.Stage
    use Glsl.Render.renderStage420
    use Glsl.Smart.uniform
    use Glsl.Smart.output
    use Glsl.Smart.extension
    use Glsl.Smart.include
    use Glsl.Smart.assign
    use Glsl.Builtin.vec4
    use Glsl.Builtin.litF
    use Glsl.Types.Vec4
    use Glsl.Expr.Expr

    @Test
    def testExtensionDirective(): Unit \ Assert =
        let frag = runBuild(_ -> {
            extension("GL_ARB_separate_shader_objects", "enable");
            let color: Expr[Vec4] = output(0, "fragColor");
            assign(color, vec4(litF(1.0f32), litF(0.0f32), litF(0.0f32), litF(1.0f32)))
        });
        let glsl = renderStage420(Stage.Fragment, frag);
        Assert.assertEq(expected = true, String.contains({substr = "#extension GL_ARB_separate_shader_objects : enable"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "#version 420 core"}, glsl))

    @Test
    def testIncludeDirective(): Unit \ Assert =
        let frag = runBuild(_ -> {
            include("common.glsl");
            let color: Expr[Vec4] = output(0, "fragColor");
            assign(color, vec4(litF(1.0f32), litF(1.0f32), litF(1.0f32), litF(1.0f32)))
        });
        let glsl = renderStage420(Stage.Fragment, frag);
        Assert.assertEq(expected = true, String.contains({substr = "#include \"common.glsl\""}, glsl))

    @Test
    def testMultipleExtensionsAndIncludes(): Unit \ Assert =
        let frag = runBuild(_ -> {
            extension("GL_ARB_separate_shader_objects", "enable");
            extension("GL_ARB_shading_language_420pack", "enable");
            include("common.glsl");
            include("utils.glsl");
            let color: Expr[Vec4] = output(0, "fragColor");
            assign(color, vec4(litF(0.5f32), litF(0.5f32), litF(0.5f32), litF(1.0f32)))
        });
        let glsl = renderStage420(Stage.Fragment, frag);
        Assert.assertEq(expected = true, String.contains({substr = "#extension GL_ARB_separate_shader_objects : enable"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "#extension GL_ARB_shading_language_420pack : enable"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "#include \"common.glsl\""}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "#include \"utils.glsl\""}, glsl))

    @Test
    def testExtensionBehaviors(): Unit \ Assert =
        let frag = runBuild(_ -> {
            extension("GL_GOOGLE_cpp_style_line_directive", "enable");
            extension("GL_GOOGLE_include_directive", "require");
            let color: Expr[Vec4] = output(0, "fragColor");
            assign(color, vec4(litF(1.0f32), litF(1.0f32), litF(1.0f32), litF(1.0f32)))
        });
        let glsl = renderStage420(Stage.Fragment, frag);
        Assert.assertEq(expected = true, String.contains({substr = "#extension GL_GOOGLE_cpp_style_line_directive : enable"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "#extension GL_GOOGLE_include_directive : require"}, glsl))

    @Test
    def testGLSL420PreambleOrder(): Unit \ Assert =
        let frag = runBuild(_ -> {
            extension("GL_ARB_separate_shader_objects", "enable");
            include("header.glsl");
            let uColor: Expr[Vec4] = uniform("uColor");
            let color: Expr[Vec4] = output(0, "fragColor");
            assign(color, uColor)
        });
        let glsl = renderStage420(Stage.Fragment, frag);
        Assert.assertEq(expected = true, String.contains({substr = "#version 420 core"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "#extension GL_ARB_separate_shader_objects : enable"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "#include \"header.glsl\""}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "uniform vec4 uColor;"}, glsl));
        Assert.assertEq(expected = true, String.contains({substr = "void main"}, glsl))
}
