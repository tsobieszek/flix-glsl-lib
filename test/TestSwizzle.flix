mod TestSwizzle {

    use Glsl.Expr.render
    use Glsl.Builtin.vec2
    use Glsl.Builtin.vec3
    use Glsl.Builtin.vec4
    use Glsl.Builtin.litF
    use Glsl.Swizzle.x
    use Glsl.Swizzle.y
    use Glsl.Swizzle.z
    use Glsl.Swizzle.w
    use Glsl.Swizzle.xy
    use Glsl.Swizzle.xz
    use Glsl.Swizzle.yz
    use Glsl.Swizzle.zw
    use Glsl.Swizzle.xyz
    use Glsl.Swizzle.xyw
    use Glsl.Swizzle.rgb
    use Glsl.Swizzle.rgba

    @Test
    def testSwizzleX(): Unit \ Assert = {
        let v2 = vec2(litF(1.0f32), litF(2.0f32));
        let v3 = vec3(litF(1.0f32), litF(2.0f32), litF(3.0f32));
        let v4 = vec4(litF(1.0f32), litF(2.0f32), litF(3.0f32), litF(4.0f32));
        Assert.assertEq(expected = "vec2(1.0, 2.0).x", render(x(v2)));
        Assert.assertEq(expected = "vec3(1.0, 2.0, 3.0).x", render(x(v3)));
        Assert.assertEq(expected = "vec4(1.0, 2.0, 3.0, 4.0).x", render(x(v4)))
    }

    @Test
    def testSwizzleY(): Unit \ Assert = {
        let v2 = vec2(litF(1.0f32), litF(2.0f32));
        let v3 = vec3(litF(1.0f32), litF(2.0f32), litF(3.0f32));
        let v4 = vec4(litF(1.0f32), litF(2.0f32), litF(3.0f32), litF(4.0f32));
        Assert.assertEq(expected = "vec2(1.0, 2.0).y", render(y(v2)));
        Assert.assertEq(expected = "vec3(1.0, 2.0, 3.0).y", render(y(v3)));
        Assert.assertEq(expected = "vec4(1.0, 2.0, 3.0, 4.0).y", render(y(v4)))
    }

    @Test
    def testSwizzleZ(): Unit \ Assert = {
        let v3 = vec3(litF(1.0f32), litF(2.0f32), litF(3.0f32));
        let v4 = vec4(litF(1.0f32), litF(2.0f32), litF(3.0f32), litF(4.0f32));
        Assert.assertEq(expected = "vec3(1.0, 2.0, 3.0).z", render(z(v3)));
        Assert.assertEq(expected = "vec4(1.0, 2.0, 3.0, 4.0).z", render(z(v4)))
    }

    @Test
    def testSwizzleW(): Unit \ Assert = {
        let v4 = vec4(litF(1.0f32), litF(2.0f32), litF(3.0f32), litF(4.0f32));
        Assert.assertEq(expected = "vec4(1.0, 2.0, 3.0, 4.0).w", render(w(v4)))
    }

    @Test
    def testSwizzleXY(): Unit \ Assert = {
        let v2 = vec2(litF(1.0f32), litF(2.0f32));
        let v3 = vec3(litF(1.0f32), litF(2.0f32), litF(3.0f32));
        let v4 = vec4(litF(1.0f32), litF(2.0f32), litF(3.0f32), litF(4.0f32));
        Assert.assertEq(expected = "vec2(1.0, 2.0).xy", render(xy(v2)));
        Assert.assertEq(expected = "vec3(1.0, 2.0, 3.0).xy", render(xy(v3)));
        Assert.assertEq(expected = "vec4(1.0, 2.0, 3.0, 4.0).xy", render(xy(v4)))
    }

    @Test
    def testSwizzleXYZ(): Unit \ Assert = {
        let v3 = vec3(litF(1.0f32), litF(2.0f32), litF(3.0f32));
        let v4 = vec4(litF(1.0f32), litF(2.0f32), litF(3.0f32), litF(4.0f32));
        Assert.assertEq(expected = "vec3(1.0, 2.0, 3.0).xyz", render(xyz(v3)));
        Assert.assertEq(expected = "vec4(1.0, 2.0, 3.0, 4.0).xyz", render(xyz(v4)))
    }

    @Test
    def testSwizzleRGB(): Unit \ Assert = {
        let v3 = vec3(litF(1.0f32), litF(2.0f32), litF(3.0f32));
        let v4 = vec4(litF(1.0f32), litF(2.0f32), litF(3.0f32), litF(4.0f32));
        Assert.assertEq(expected = "vec3(1.0, 2.0, 3.0).rgb", render(rgb(v3)));
        Assert.assertEq(expected = "vec4(1.0, 2.0, 3.0, 4.0).rgb", render(rgb(v4)))
    }

    @Test
    def testSwizzleRGBA(): Unit \ Assert = {
        let v4 = vec4(litF(1.0f32), litF(2.0f32), litF(3.0f32), litF(4.0f32));
        Assert.assertEq(expected = "vec4(1.0, 2.0, 3.0, 4.0).rgba", render(rgba(v4)))
    }
}
