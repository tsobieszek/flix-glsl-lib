mod TestComments {
    use Glsl.Build.runBuild
    use Glsl.Smart.comment
    use Glsl.Smart.blockComment

    @Test
    pub def testCommentsFeature(): Unit \ Assert = {
        let src = runBuild(_ -> {
            comment("Single line comment");
            blockComment("Multi-line block comment");
            comment("Another comment");
            ()
        });

        let hasLine1 = src#body |> Vector.exists(s ->
            String.contains({substr = "Single line comment"}, Glsl.Ast.renderStmt(s) |> Vector.toList |> String.unlines));
        let hasBlock = src#body |> Vector.exists(s ->
            String.contains({substr = "Multi-line block comment"}, Glsl.Ast.renderStmt(s) |> Vector.toList |> String.unlines));
        let hasLine2 = src#body |> Vector.exists(s ->
            String.contains({substr = "Another comment"}, Glsl.Ast.renderStmt(s) |> Vector.toList |> String.unlines));

        Assert.assertTrue(hasLine1);
        Assert.assertTrue(hasBlock);
        Assert.assertTrue(hasLine2)
    }
}
