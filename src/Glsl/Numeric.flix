///
/// `Glsl.Numeric` — operator-overload validation, addressing the
/// "GLSL operator overloading is not single-trait-friendly" question
/// from `ADDITIONAL_INSIGHTS.md`.
///
/// Three families of GLSL `*` exist:
///
///   1. Same-type elementwise:  `vec3 * vec3`, `float * float` — fits
///      a single trait `Mul[t] { def mul(t, t): t }`.
///   2. Scalar broadcast:       `vec3 * float`, `mat4 * float`        — heterogeneous
///      operands, result type matches the LHS.
///   3. Linear:                 `mat4 * vec4`, `mat4 * mat4`          — heterogeneous,
///      result type can differ from both operands.
///
/// We test the cleanest Flix shape for (1) here — a real trait — and
/// keep (2) and (3) as hand-written helpers in `Glsl.Builtin`. The
/// design conclusion: Flix 0.72.0 has no associated types and no
/// multi-parameter type classes with output types, so a unified trait
/// covering all three cases is not yet expressible.
///
/// What works: a homogeneous `Mul[t]` trait usable for `vec3*vec3`,
/// `vec4*vec4`, `float*float`. The compiler picks the right instance
/// from the operand types alone — no Proxy needed because both
/// arguments have type `Expr[t]`.
///
pub mod Glsl.Numeric {

    use Glsl.Expr.Expr
    use Glsl.Expr.boxed
    use Glsl.Types.Vec2
    use Glsl.Types.Vec3
    use Glsl.Types.Vec4

    pub trait Mul[t] {
        pub def mul(x: Expr[t], y: Expr[t]): Expr[t]
    }

    instance Mul[Float32] {
        pub def mul(x: Expr[Float32], y: Expr[Float32]): Expr[Float32] =
            Expr.BinOp("*", boxed(x), boxed(y))
    }

    instance Mul[Vec2] {
        pub def mul(x: Expr[Vec2], y: Expr[Vec2]): Expr[Vec2] =
            Expr.BinOp("*", boxed(x), boxed(y))
    }

    instance Mul[Vec3] {
        pub def mul(x: Expr[Vec3], y: Expr[Vec3]): Expr[Vec3] =
            Expr.BinOp("*", boxed(x), boxed(y))
    }

    instance Mul[Vec4] {
        pub def mul(x: Expr[Vec4], y: Expr[Vec4]): Expr[Vec4] =
            Expr.BinOp("*", boxed(x), boxed(y))
    }

    instance Mul[Glsl.Types.Mat2] {
        pub def mul(x: Expr[Glsl.Types.Mat2], y: Expr[Glsl.Types.Mat2]): Expr[Glsl.Types.Mat2] =
            Expr.BinOp("*", boxed(x), boxed(y))
    }

    instance Mul[Glsl.Types.Mat3] {
        pub def mul(x: Expr[Glsl.Types.Mat3], y: Expr[Glsl.Types.Mat3]): Expr[Glsl.Types.Mat3] =
            Expr.BinOp("*", boxed(x), boxed(y))
    }

    instance Mul[Glsl.Types.Mat4] {
        pub def mul(x: Expr[Glsl.Types.Mat4], y: Expr[Glsl.Types.Mat4]): Expr[Glsl.Types.Mat4] =
            Expr.BinOp("*", boxed(x), boxed(y))
    }

    pub trait Add[t] {
        pub def add(x: Expr[t], y: Expr[t]): Expr[t]
    }

    instance Add[Float32] {
        pub def add(x: Expr[Float32], y: Expr[Float32]): Expr[Float32] =
            Expr.BinOp("+", boxed(x), boxed(y))
    }

    instance Add[Vec2] {
        pub def add(x: Expr[Vec2], y: Expr[Vec2]): Expr[Vec2] =
            Expr.BinOp("+", boxed(x), boxed(y))
    }

    instance Add[Vec3] {
        pub def add(x: Expr[Vec3], y: Expr[Vec3]): Expr[Vec3] =
            Expr.BinOp("+", boxed(x), boxed(y))
    }

    instance Add[Vec4] {
        pub def add(x: Expr[Vec4], y: Expr[Vec4]): Expr[Vec4] =
            Expr.BinOp("+", boxed(x), boxed(y))
    }

    pub trait Sub[t] {
        pub def sub(x: Expr[t], y: Expr[t]): Expr[t]
    }

    instance Sub[Float32] {
        pub def sub(x: Expr[Float32], y: Expr[Float32]): Expr[Float32] =
            Expr.BinOp("-", boxed(x), boxed(y))
    }

    instance Sub[Vec2] {
        pub def sub(x: Expr[Vec2], y: Expr[Vec2]): Expr[Vec2] =
            Expr.BinOp("-", boxed(x), boxed(y))
    }

    instance Sub[Vec3] {
        pub def sub(x: Expr[Vec3], y: Expr[Vec3]): Expr[Vec3] =
            Expr.BinOp("-", boxed(x), boxed(y))
    }

    instance Sub[Vec4] {
        pub def sub(x: Expr[Vec4], y: Expr[Vec4]): Expr[Vec4] =
            Expr.BinOp("-", boxed(x), boxed(y))
    }

    pub trait Div[t] {
        pub def div(x: Expr[t], y: Expr[t]): Expr[t]
    }

    instance Div[Float32] {
        pub def div(x: Expr[Float32], y: Expr[Float32]): Expr[Float32] =
            Expr.BinOp("/", boxed(x), boxed(y))
    }

    instance Div[Vec2] {
        pub def div(x: Expr[Vec2], y: Expr[Vec2]): Expr[Vec2] =
            Expr.BinOp("/", boxed(x), boxed(y))
    }

    instance Div[Vec3] {
        pub def div(x: Expr[Vec3], y: Expr[Vec3]): Expr[Vec3] =
            Expr.BinOp("/", boxed(x), boxed(y))
    }

    instance Div[Vec4] {
        pub def div(x: Expr[Vec4], y: Expr[Vec4]): Expr[Vec4] =
            Expr.BinOp("/", boxed(x), boxed(y))
    }
}
