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
                discard (structMemberTyped("color", (Proxy.Proxy: Proxy[Vec3])): Expr[Vec3])
            });

            declareInterfaceBlock("out", "VertexOut", "vertexOut", _ -> {
                discard (structMemberTyped("uv", (Proxy.Proxy: Proxy[Vec2])): Expr[Vec2])
            })
        });

        let hasStruct = src#functions |> Vector.exists(line -> 
            String.contains({substr = "struct Light"}, line));
        let hasInterface = src#functions |> Vector.exists(line -> 
            String.contains({substr = "struct VertexOut"}, line));
        let hasInstance = src#functions |> Vector.exists(line -> 
            String.contains({substr = "vertexOut;"}, line));

        Assert.assertTrue(hasStruct);
        Assert.assertTrue(hasInterface);
        Assert.assertTrue(hasInstance)
    }
}
