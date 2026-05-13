mod TestVariants {

    use Glsl.Build.runBuild
    use Glsl.Smart.constVar
    use Glsl.Smart.glPosition
    use Glsl.Builtin.normalize
    use Glsl.Variants.Param
    use Glsl.Variants.ParamCombo
    use Glsl.Variants.flag

    @Test
    pub def testMacroSimulationPattern(): Unit \ Assert = {
        let combo: ParamCombo = Vector#{Param.Flag("useTangent", true)};
        let src = runBuild(_ -> {
            let useTangent = flag("useTangent", combo);
            if (useTangent)
                discard constVar("N", normalize(glPosition()))
            else
                discard constVar("N", glPosition());
            ()
        });

        let hasTangentLogic = src#body |> Vector.exists(s ->
            String.contains({substr = "normalize"}, Glsl.Ast.renderStmt(s) |> Vector.toList |> String.unlines));
        Assert.assertTrue(hasTangentLogic)
    }
}
