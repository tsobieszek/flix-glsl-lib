mod TestMath {

    use Glsl.Expr.render
    use Glsl.Builtin.litF
    use Glsl.Builtin.litI
    use Glsl.Builtin.vec2
    use Glsl.Builtin.vec3
    use Glsl.Builtin.vec4
    use Glsl.Builtin.sin
    use Glsl.Builtin.sqrt
    use Glsl.Builtin.pow
    use Glsl.Builtin.dot
    use Glsl.Builtin.cross
    use Glsl.Builtin.normalize
    use Glsl.Builtin.neg
    use Glsl.Numeric.Add
    use Glsl.Numeric.Sub
    use Glsl.Numeric.Mul
    use Glsl.Numeric.Div

    @Test
    pub def testArithmetic01(): Unit \ Assert = {
        let a = litF(1.0f32);
        let b = litF(2.0f32);
        Assert.assertEq(expected = "(1.0 + 2.0)", render(Add.add(a, b)));
        Assert.assertEq(expected = "(1.0 - 2.0)", render(Sub.sub(a, b)));
        Assert.assertEq(expected = "(1.0 * 2.0)", render(Mul.mul(a, b)));
        Assert.assertEq(expected = "(1.0 / 2.0)", render(Div.div(a, b)))
    }

    @Test
    pub def testArithmetic02(): Unit \ Assert = {
        let v1 = vec3(litF(1.0f32), litF(2.0f32), litF(3.0f32));
        let v2 = vec3(litF(4.0f32), litF(5.0f32), litF(6.0f32));
        Assert.assertEq(expected = "(vec3(1.0, 2.0, 3.0) + vec3(4.0, 5.0, 6.0))", render(Add.add(v1, v2)));
        Assert.assertEq(expected = "(vec3(1.0, 2.0, 3.0) - vec3(4.0, 5.0, 6.0))", render(Sub.sub(v1, v2)));
        Assert.assertEq(expected = "(vec3(1.0, 2.0, 3.0) * vec3(4.0, 5.0, 6.0))", render(Mul.mul(v1, v2)));
        Assert.assertEq(expected = "(vec3(1.0, 2.0, 3.0) / vec3(4.0, 5.0, 6.0))", render(Div.div(v1, v2)))
    }

    @Test
    pub def testBuiltins01(): Unit \ Assert = {
        let x = litF(0.5f32);
        Assert.assertEq(expected = "sin(0.5)", render(sin(x)));
        Assert.assertEq(expected = "sqrt(0.5)", render(sqrt(x)));
        Assert.assertEq(expected = "pow(0.5, 0.5)", render(pow(x, x)))
    }

    @Test
    pub def testBuiltins02(): Unit \ Assert = {
        let v1 = vec3(litF(1.0f32), litF(0.0f32), litF(0.0f32));
        let v2 = vec3(litF(0.0f32), litF(1.0f32), litF(0.0f32));
        Assert.assertEq(expected = "dot(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0))", render(dot(v1, v2)));
        Assert.assertEq(expected = "cross(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0))", render(cross(v1, v2)));
        Assert.assertEq(expected = "normalize(vec3(1.0, 0.0, 0.0))", render(normalize(v1)))
    }

    @Test
    pub def testUnary01(): Unit \ Assert = {
        let x = litF(1.0f32);
        Assert.assertEq(expected = "(-1.0)", render(neg(x)))
    }

    @Test
    pub def testInt01(): Unit \ Assert = {
        let i = litI(42);
        Assert.assertEq(expected = "42", render(i))
    }
}
