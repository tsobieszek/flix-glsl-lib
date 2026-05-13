mod TestStructs {
    use Glsl.Build.runBuild
    use Glsl.Expr.Expr
    use Glsl.Smart.declareStruct
    use Glsl.Smart.structMember
    use Glsl.Smart.structMemberTyped
    use Glsl.Smart.declareInterfaceBlock
    use Glsl.Types.Vec2
    use Glsl.Types.Vec3

    @Test
    pub def testStructsAndInterfaceBlocks(): Unit \ Assert = {
        let src = runBuild(_ -> {
            declareStruct("Light", _ -> {
                discard structMemberTyped("pos", (Proxy.Proxy: Proxy[Vec3]));
                discard (structMemberTyped("color", (Proxy.Proxy: Proxy[Vec3])): Expr[Vec3]);
                ()
            });

            declareInterfaceBlock("out", "VertexOut", "vertexOut", _ -> {
                discard (structMemberTyped("uv", (Proxy.Proxy: Proxy[Vec2])): Expr[Vec2]);
                ()
            });
            ()
        });

        let hasStruct = src#topLevels |> Vector.exists(t ->
            String.contains({substr = "Light"}, Glsl.Ast.renderTopLevel(t)));
        let hasInterface = src#topLevels |> Vector.exists(t ->
            String.contains({substr = "VertexOut"}, Glsl.Ast.renderTopLevel(t)));
        let hasInstance = src#topLevels |> Vector.exists(t ->
            String.contains({substr = "vertexOut"}, Glsl.Ast.renderTopLevel(t)));

        Assert.assertTrue(hasStruct);
        Assert.assertTrue(hasInterface);
        Assert.assertTrue(hasInstance)
    }
}
