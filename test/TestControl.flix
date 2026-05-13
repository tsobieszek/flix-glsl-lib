mod TestControl {

    use Glsl.Build.runBuild
    use Glsl.Build.Build
    use Glsl.Stage.Stage
    use Glsl.Render.renderStage
    use Glsl.Smart.ifStmt
    use Glsl.Smart.elseStmt
    use Glsl.Smart.forLoop
    use Glsl.Smart.whileLoop
    use Glsl.Smart.breakStmt
    use Glsl.Smart.continueStmt
    use Glsl.Smart.assign
    use Glsl.Smart.defineFunction
    use Glsl.Smart.param
    use Glsl.Smart.returnExpr
    use Glsl.Smart.floatVar
    use Glsl.Builtin.litF
    use Glsl.Builtin.lt
    use Glsl.Builtin.addF
    use Glsl.Builtin.call
    use Glsl.Expr.boxed
    use Glsl.Expr.Expr
    use Glsl.Expr.Ast
    use Glsl.Types.floatTy

    @Test
    def testForLoop(): Unit \ Assert = {
        let src = runBuild(_ -> {
            forLoop("int i = 0", lt(Expr.Of(Ast.Var("i")), Expr.Of(Ast.Lit("10"))), "i++", _ -> {
                assign(Expr.Of(Ast.Var("x")), addF(Expr.Of(Ast.Var("x")), litF(1.0f32)))
            })
        });
        let glsl = renderStage(Stage.Fragment, src);
        Assert.assertEq(expected = true, String.contains(substr = "for (int i = 0; (i < 10); i++) {", glsl));
        Assert.assertEq(expected = true, String.contains(substr = "x = (x + 1.0);", glsl))
    }

    @Test
    def testWhileLoop(): Unit \ Assert = {
        let src = runBuild(_ -> {
            whileLoop(lt(Expr.Of(Ast.Var("x")), litF(10.0f32)), _ -> {
                ifStmt(lt(Expr.Of(Ast.Var("x")), litF(5.0f32)), _ -> {
                    continueStmt()
                });
                assign(Expr.Of(Ast.Var("x")), addF(Expr.Of(Ast.Var("x")), litF(1.0f32)));
                ifStmt(lt(Expr.Of(Ast.Var("x")), litF(9.0f32)), _ -> {
                    breakStmt()
                })
            })
        });
        let glsl = renderStage(Stage.Fragment, src);
        Assert.assertEq(expected = true, String.contains(substr = "while ((x < 10.0)) {", glsl));
        Assert.assertEq(expected = true, String.contains(substr = "continue;", glsl));
        Assert.assertEq(expected = true, String.contains(substr = "break;", glsl))
    }

    @Test
    def testUserFunction(): Unit \ Assert = {
        let src = runBuild(_ -> {
            defineFunction("myFunc", floatTy(), List#{param("x", floatTy()), param("y", floatTy())}, _ -> {
                returnExpr(addF(Expr.Of(Ast.Var("x")), Expr.Of(Ast.Var("y"))))
            });
            let res = floatVar("res");
            assign(res, call("myFunc", Vector#{boxed(litF(1.0f32)), boxed(litF(2.0f32))}))
        });
        let glsl = renderStage(Stage.Fragment, src);
        Assert.assertEq(expected = true, String.contains(substr = "float myFunc(float x, float y) {", glsl));
        Assert.assertEq(expected = true, String.contains(substr = "return (x + y);", glsl));
        Assert.assertEq(expected = true, String.contains(substr = "res = myFunc(1.0, 2.0);", glsl))
    }
}