mod TestCasting {
    use Glsl.Expr.render
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
        let i: Expr[Int32] = Glsl.Expr.Var("someInt");

        Assert.assertEq(expected = "float(someInt)", render(asFloat(i)));
        Assert.assertEq(expected = "int(3.14)", render(asInt(f)));
        Assert.assertEq(expected = "uint(3.14)", render(asUint(f)));
        Assert.assertEq(expected = "bool(3.14)", render(asBool(f)))
    }

    @Test
    pub def testGenericCast(): Unit \ Assert = {
        let f = litF(3.14f32);
        let c: Expr[Int32] = cast(f);
        Assert.assertEq(expected = "(3.14)", render(c))
    }
}
