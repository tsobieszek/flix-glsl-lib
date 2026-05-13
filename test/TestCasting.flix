mod TestCasting {
    use Glsl.Expr.renderExpr
    use Glsl.Expr.Expr
    use Glsl.Builtin.litF
    use Glsl.Builtin.asFloat
    use Glsl.Builtin.asInt
    use Glsl.Builtin.asUint
    use Glsl.Builtin.asBool
    use Glsl.Builtin.cast

    @Test
    pub def testTypeCastingFunctions(): Unit \ Assert = {
        let f = litF(3.14f32);
        let i: Expr[Int32] = Expr.Of(Glsl.Expr.Ast.Var("someInt"));

        Assert.assertEq(expected = "float(someInt)", renderExpr(asFloat(i)));
        Assert.assertEq(expected = "int(3.14)", renderExpr(asInt(f)));
        Assert.assertEq(expected = "uint(3.14)", renderExpr(asUint(f)));
        Assert.assertEq(expected = "bool(3.14)", renderExpr(asBool(f)))
    }

    @Test
    pub def testGenericCast(): Unit \ Assert = {
        let f = litF(3.14f32);
        let c: Expr[Int32] = cast(f);
        Assert.assertEq(expected = "(3.14)", renderExpr(c))
    }
}
