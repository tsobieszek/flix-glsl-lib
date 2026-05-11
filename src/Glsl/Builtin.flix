///
/// `Glsl.Builtin` — a minimal set of GLSL built-in functions and
/// constructors used by the example shader.
///
/// One polymorphic helper per builtin: the type parameter `t` is
/// enforced by the host language, the GLSL string is constructed once.
/// We're not aiming at completeness here — this is a proof-of-concept
/// with comprehensive coverage of common functions and constructors.
///
pub mod Glsl.Builtin {

    use Glsl.Expr.Expr
    use Glsl.Expr.RenderedExpr
    use Glsl.Expr.boxed
    use Glsl.Types.Vec2
    use Glsl.Types.Vec3
    use Glsl.Types.Vec4
    use Glsl.Types.IVec2
    use Glsl.Types.IVec3
    use Glsl.Types.IVec4
    use Glsl.Types.UVec2
    use Glsl.Types.UVec3
    use Glsl.Types.UVec4
    use Glsl.Types.BVec2
    use Glsl.Types.BVec3
    use Glsl.Types.BVec4
    use Glsl.Types.Mat4
    use Glsl.Types.Sampler2D
    use Glsl.Types.SamplerCube
    use Glsl.Types.Sampler2DArray
    use Glsl.Types.Sampler3D
    use Glsl.Types.GlslArray

    ///
    /// Float literal.
    ///
    pub def litF(x: Float32): Expr[Float32] =
        Expr.Lit("${x}")

    ///
    /// Bool literal.
    ///
    pub def litB(x: Bool): Expr[Bool] =
        Expr.Lit("${x}")

    ///
    /// Int literal.
    ///
    pub def litI(x: Int32): Expr[Int32] =
        Expr.Lit("${x}")

    ///
    /// Unsigned int literal — emits the GLSL `u` suffix (e.g. `1u`).
    ///
    /// Flix 0.72.0 has no unsigned scalar primitive, so the host argument
    /// stays `Int32`; the suffix is added at render time. Use this in
    /// `uvec*` constructors to produce idiomatic GLSL ES 300.
    ///
    pub def litU(x: Int32): Expr[Int32] =
        Expr.Lit("${x}u")

    ///
    /// `ivec2(x, y)`.
    ///
    pub def ivec2(x: Expr[Int32], y: Expr[Int32]): Expr[IVec2] =
        Expr.App("ivec2", List#{boxed(x), boxed(y)})

    ///
    /// `ivec3(x, y, z)`.
    ///
    pub def ivec3(x: Expr[Int32], y: Expr[Int32], z: Expr[Int32]): Expr[IVec3] =
        Expr.App("ivec3", List#{boxed(x), boxed(y), boxed(z)})

    ///
    /// `ivec4(x, y, z, w)`.
    ///
    pub def ivec4(x: Expr[Int32], y: Expr[Int32], z: Expr[Int32], w: Expr[Int32]): Expr[IVec4] =
        Expr.App("ivec4", List#{boxed(x), boxed(y), boxed(z), boxed(w)})

    ///
    /// `uvec2(x, y)`.
    ///
    /// Flix 0.72.0 has no unsigned primitive, so the constructor helpers
    /// take signed `Int32` expressions and emit GLSL `uvec*` syntax.
    ///
    pub def uvec2(x: Expr[Int32], y: Expr[Int32]): Expr[UVec2] =
        Expr.App("uvec2", List#{boxed(x), boxed(y)})

    ///
    /// `uvec3(x, y, z)`.
    ///
    pub def uvec3(x: Expr[Int32], y: Expr[Int32], z: Expr[Int32]): Expr[UVec3] =
        Expr.App("uvec3", List#{boxed(x), boxed(y), boxed(z)})

    ///
    /// `uvec4(x, y, z, w)`.
    ///
    pub def uvec4(x: Expr[Int32], y: Expr[Int32], z: Expr[Int32], w: Expr[Int32]): Expr[UVec4] =
        Expr.App("uvec4", List#{boxed(x), boxed(y), boxed(z), boxed(w)})

    ///
    /// `bvec2(x, y)`.
    ///
    pub def bvec2(x: Expr[Bool], y: Expr[Bool]): Expr[BVec2] =
        Expr.App("bvec2", List#{boxed(x), boxed(y)})

    ///
    /// `bvec3(x, y, z)`.
    ///
    pub def bvec3(x: Expr[Bool], y: Expr[Bool], z: Expr[Bool]): Expr[BVec3] =
        Expr.App("bvec3", List#{boxed(x), boxed(y), boxed(z)})

    ///
    /// `bvec4(x, y, z, w)`.
    ///
    pub def bvec4(x: Expr[Bool], y: Expr[Bool], z: Expr[Bool], w: Expr[Bool]): Expr[BVec4] =
        Expr.App("bvec4", List#{boxed(x), boxed(y), boxed(z), boxed(w)})

    ///
    /// `vec2(x, y)`.
    ///
    pub def vec2(x: Expr[Float32], y: Expr[Float32]): Expr[Vec2] =
        Expr.App("vec2", List#{boxed(x), boxed(y)})

    ///
    /// `vec3(x, y, z)`.
    ///
    pub def vec3(x: Expr[Float32], y: Expr[Float32], z: Expr[Float32]): Expr[Vec3] =
        Expr.App("vec3", List#{boxed(x), boxed(y), boxed(z)})

    ///
    /// `vec4(x, y, z, w)`.
    ///
    pub def vec4(x: Expr[Float32], y: Expr[Float32], z: Expr[Float32], w: Expr[Float32]): Expr[Vec4] =
        Expr.App("vec4", List#{boxed(x), boxed(y), boxed(z), boxed(w)})

    ///
    /// `vec4(xyz, w)` — vec3 + float.
    ///
    pub def vec4FromVec3(xyz: Expr[Vec3], w: Expr[Float32]): Expr[Vec4] =
        Expr.App("vec4", List#{boxed(xyz), boxed(w)})

    ///
    /// `mat3(c0, c1, c2)` — mat3 from three column vec3s.
    ///
    pub def mat3(c0: Expr[Vec3], c1: Expr[Vec3], c2: Expr[Vec3]): Expr[Glsl.Types.Mat3] =
        Expr.App("mat3", List#{boxed(c0), boxed(c1), boxed(c2)})

    ///
    /// `radians(degrees)`
    ///
    pub def radians(x: Expr[t]): Expr[t] =
        Expr.App("radians", List#{boxed(x)})

    ///
    /// `degrees(radians)`
    ///
    pub def degrees(x: Expr[t]): Expr[t] =
        Expr.App("degrees", List#{boxed(x)})

    ///
    /// `sin(x)` — polymorphic across `Float32`, `Vec2`, `Vec3`, `Vec4`.
    ///
    pub def sin(x: Expr[t]): Expr[t] =
        Expr.App("sin", List#{boxed(x)})

    ///
    /// `cos(x)`.
    ///
    pub def cos(x: Expr[t]): Expr[t] =
        Expr.App("cos", List#{boxed(x)})

    ///
    /// `tan(x)`.
    ///
    pub def tan(x: Expr[t]): Expr[t] =
        Expr.App("tan", List#{boxed(x)})

    ///
    /// `asin(x)`.
    ///
    pub def asin(x: Expr[t]): Expr[t] =
        Expr.App("asin", List#{boxed(x)})

    ///
    /// `acos(x)`.
    ///
    pub def acos(x: Expr[t]): Expr[t] =
        Expr.App("acos", List#{boxed(x)})

    ///
    /// `atan(y, x)` or `atan(y_over_x)`.
    ///
    pub def atan(y: Expr[t], x: Expr[t]): Expr[t] =
        Expr.App("atan", List#{boxed(y), boxed(x)})

    ///
    /// `atan(y_over_x)`.
    ///
    pub def atan1(y_over_x: Expr[t]): Expr[t] =
        Expr.App("atan", List#{boxed(y_over_x)})

    ///
    /// `pow(x, y)`.
    ///
    pub def pow(x: Expr[t], y: Expr[t]): Expr[t] =
        Expr.App("pow", List#{boxed(x), boxed(y)})

    ///
    /// `exp(x)`.
    ///
    pub def exp(x: Expr[t]): Expr[t] =
        Expr.App("exp", List#{boxed(x)})

    ///
    /// `log(x)`.
    ///
    pub def log(x: Expr[t]): Expr[t] =
        Expr.App("log", List#{boxed(x)})

    ///
    /// `exp2(x)`.
    ///
    pub def exp2(x: Expr[t]): Expr[t] =
        Expr.App("exp2", List#{boxed(x)})

    ///
    /// `log2(x)`.
    ///
    pub def log2(x: Expr[t]): Expr[t] =
        Expr.App("log2", List#{boxed(x)})

    ///
    /// `sqrt(x)`.
    ///
    pub def sqrt(x: Expr[t]): Expr[t] =
        Expr.App("sqrt", List#{boxed(x)})

    ///
    /// `inversesqrt(x)`.
    ///
    pub def inversesqrt(x: Expr[t]): Expr[t] =
        Expr.App("inversesqrt", List#{boxed(x)})

    ///
    /// `abs(x)`.
    ///
    pub def abs(x: Expr[t]): Expr[t] =
        Expr.App("abs", List#{boxed(x)})

    ///
    /// `sign(x)`.
    ///
    pub def sign(x: Expr[t]): Expr[t] =
        Expr.App("sign", List#{boxed(x)})

    ///
    /// `floor(x)`.
    ///
    pub def floor(x: Expr[t]): Expr[t] =
        Expr.App("floor", List#{boxed(x)})

    ///
    /// `ceil(x)`.
    ///
    pub def ceil(x: Expr[t]): Expr[t] =
        Expr.App("ceil", List#{boxed(x)})

    ///
    /// `fract(x)`.
    ///
    pub def fract(x: Expr[t]): Expr[t] =
        Expr.App("fract", List#{boxed(x)})

    ///
    /// `mod(x, y)`.
    ///
    pub def modF(x: Expr[t], y: Expr[t]): Expr[t] =
        Expr.App("mod", List#{boxed(x), boxed(y)})

    ///
    /// `mod(x, s)` — vector % scalar.
    ///
    pub def modS(x: Expr[t], s: Expr[Float32]): Expr[t] =
        Expr.App("mod", List#{boxed(x), boxed(s)})

    ///
    /// `min(x, y)`.
    ///
    pub def min(x: Expr[t], y: Expr[t]): Expr[t] =
        Expr.App("min", List#{boxed(x), boxed(y)})

    ///
    /// `min(x, s)` — vector/scalar min.
    ///
    pub def minS(x: Expr[t], s: Expr[Float32]): Expr[t] =
        Expr.App("min", List#{boxed(x), boxed(s)})

    ///
    /// `max(x, y)`.
    ///
    pub def max(x: Expr[t], y: Expr[t]): Expr[t] =
        Expr.App("max", List#{boxed(x), boxed(y)})

    ///
    /// `max(x, s)` — vector/scalar max.
    ///
    pub def maxS(x: Expr[t], s: Expr[Float32]): Expr[t] =
        Expr.App("max", List#{boxed(x), boxed(s)})

    ///
    /// `clamp(x, lo, hi)`.
    ///
    pub def clamp(x: Expr[t], lo: Expr[t], hi: Expr[t]): Expr[t] =
        Expr.App("clamp", List#{boxed(x), boxed(lo), boxed(hi)})

    ///
    /// `clamp(x, lo, hi)` — vector with scalar limits.
    ///
    pub def clampS(x: Expr[t], lo: Expr[Float32], hi: Expr[Float32]): Expr[t] =
        Expr.App("clamp", List#{boxed(x), boxed(lo), boxed(hi)})

    ///
    /// `mix(a, b, t)` — linear interpolation with scalar weight.
    ///
    pub def mix(a: Expr[t], b: Expr[t], k: Expr[Float32]): Expr[t] =
        Expr.App("mix", List#{boxed(a), boxed(b), boxed(k)})

    ///
    /// `mix(a, b, t)` — linear interpolation with vector weight.
    /// Used when the weight is the same type as the interpolands (e.g., IBL specular).
    ///
    pub def mixVec(a: Expr[t], b: Expr[t], t: Expr[t]): Expr[t] =
        Expr.App("mix", List#{boxed(a), boxed(b), boxed(t)})

    ///
    /// `step(edge, x)`.
    ///
    pub def step(edge: Expr[t], x: Expr[t]): Expr[t] =
        Expr.App("step", List#{boxed(edge), boxed(x)})

    ///
    /// `step(edge, x)` — scalar edge with vector x.
    ///
    pub def stepS(edge: Expr[Float32], x: Expr[t]): Expr[t] =
        Expr.App("step", List#{boxed(edge), boxed(x)})

    ///
    /// `smoothstep(edge0, edge1, x)`.
    ///
    pub def smoothstep(edge0: Expr[t], edge1: Expr[t], x: Expr[t]): Expr[t] =
        Expr.App("smoothstep", List#{boxed(edge0), boxed(edge1), boxed(x)})

    ///
    /// `smoothstep(edge0, edge1, x)` — scalar edges with vector x.
    ///
    pub def smoothstepS(edge0: Expr[Float32], edge1: Expr[Float32], x: Expr[t]): Expr[t] =
        Expr.App("smoothstep", List#{boxed(edge0), boxed(edge1), boxed(x)})

    ///
    /// `length(x)`.
    ///
    pub def length(x: Expr[t]): Expr[Float32] =
        Expr.App("length", List#{boxed(x)})

    ///
    /// `distance(p0, p1)`.
    ///
    pub def distance(p0: Expr[t], p1: Expr[t]): Expr[Float32] =
        Expr.App("distance", List#{boxed(p0), boxed(p1)})

    ///
    /// `dot(x, y)`.
    ///
    pub def dot(x: Expr[t], y: Expr[t]): Expr[Float32] =
        Expr.App("dot", List#{boxed(x), boxed(y)})

    ///
    /// `cross(x, y)`.
    ///
    pub def cross(x: Expr[Vec3], y: Expr[Vec3]): Expr[Vec3] =
        Expr.App("cross", List#{boxed(x), boxed(y)})

    ///
    /// `normalize(x)`.
    ///
    pub def normalize(x: Expr[t]): Expr[t] =
        Expr.App("normalize", List#{boxed(x)})

    ///
    /// `reflect(I, N)`.
    ///
    pub def reflect(i: Expr[t], n: Expr[t]): Expr[t] =
        Expr.App("reflect", List#{boxed(i), boxed(n)})

    ///
    /// `refract(I, N, eta)`.
    ///
    pub def refract(i: Expr[t], n: Expr[t], eta: Expr[Float32]): Expr[t] =
        Expr.App("refract", List#{boxed(i), boxed(n), boxed(eta)})

    ///
    /// `texture(sampler, coord)`.
    ///
    pub def texture(sampler: Expr[s], coord: Expr[c]): Expr[Vec4] =
        Expr.App("texture", List#{boxed(sampler), boxed(coord)})

    ///
    /// `texture(sampler, coord, bias)`.
    ///
    pub def textureBias(sampler: Expr[s], coord: Expr[c], bias: Expr[Float32]): Expr[Vec4] =
        Expr.App("texture", List#{boxed(sampler), boxed(coord), boxed(bias)})

    ///
    /// `textureLod(sampler, coord, lod)`.
    ///
    pub def textureLod(sampler: Expr[s], coord: Expr[c], lod: Expr[Float32]): Expr[Vec4] =
        Expr.App("textureLod", List#{boxed(sampler), boxed(coord), boxed(lod)})

    ///
    /// `textureSize(sampler, lod)`. The result type depends on the sampler
    /// dimension (`IVec2` for `sampler2D`, `IVec3` for `sampler3D`, etc.);
    /// the caller is responsible for ascribing the correct phantom type.
    ///
    pub def textureSize(sampler: Expr[s], lod: Expr[Int32]): Expr[t] =
        Expr.App("textureSize", List#{boxed(sampler), boxed(lod)})

    ///
    /// `texelFetch(sampler, coord, lod)`.
    ///
    pub def texelFetch(sampler: Expr[s], coord: Expr[c], lod: Expr[Int32]): Expr[Vec4] =
        Expr.App("texelFetch", List#{boxed(sampler), boxed(coord), boxed(lod)})

    ///
    /// `arr[i]` — array indexing.
    ///
    pub def index(arr: Expr[GlslArray[t]], i: Expr[Int32]): Expr[t] =
        Expr.Index(boxed(arr), boxed(i))

    ///
    /// `mat4 * vec4` — the only operator overload with heterogeneous
    /// operand types. Hand-written rather than fitting a `Numeric` trait.
    /// See ADDITIONAL_INSIGHTS.md ("GLSL operator overloading is not
    /// single-trait-friendly") — this is the v1 approach.
    ///
    pub def mulMatVec(m: Expr[Mat4], v: Expr[Vec4]): Expr[Vec4] =
        Expr.BinOp("*", boxed(m), boxed(v))

    ///
    /// `mat3 * vec3` — matrix-vector multiplication for 3×3 matrices.
    ///
    pub def mulMat3Vec(m: Expr[Glsl.Types.Mat3], v: Expr[Vec3]): Expr[Vec3] =
        Expr.BinOp("*", boxed(m), boxed(v))

    ///
    /// `vec2 * float` — broadcast scale.
    ///
    pub def scale2(v: Expr[Vec2], s: Expr[Float32]): Expr[Vec2] =
        Expr.BinOp("*", boxed(v), boxed(s))

    ///
    /// `vec3 * float` — broadcast scale.
    ///
    pub def scale3(v: Expr[Vec3], s: Expr[Float32]): Expr[Vec3] =
        Expr.BinOp("*", boxed(v), boxed(s))

    ///
    /// `vec4 * float` — broadcast scale.
    ///
    pub def scale4(v: Expr[Vec4], s: Expr[Float32]): Expr[Vec4] =
        Expr.BinOp("*", boxed(v), boxed(s))

    ///
    /// `-x` — unary negation.
    ///
    pub def neg(x: Expr[t]): Expr[t] =
        Expr.UnOp("-", boxed(x))

    ///
    /// `vec2 + vec2`.
    ///
    pub def addV2(a: Expr[Vec2], b: Expr[Vec2]): Expr[Vec2] =
        Expr.BinOp("+", boxed(a), boxed(b))

    ///
    /// `vec3 + vec3`.
    ///
    pub def addV3(a: Expr[Vec3], b: Expr[Vec3]): Expr[Vec3] =
        Expr.BinOp("+", boxed(a), boxed(b))

    ///
    /// `vec4 + vec4`.
    ///
    pub def addV4(a: Expr[Vec4], b: Expr[Vec4]): Expr[Vec4] =
        Expr.BinOp("+", boxed(a), boxed(b))

    ///
    /// `float + float`.
    ///
    pub def addF(a: Expr[Float32], b: Expr[Float32]): Expr[Float32] =
        Expr.BinOp("+", boxed(a), boxed(b))

    ///
    /// `float * float`.
    ///
    pub def mulF(a: Expr[Float32], b: Expr[Float32]): Expr[Float32] =
        Expr.BinOp("*", boxed(a), boxed(b))

    ///
    /// `float / float` — floating-point division.
    ///
    pub def divF(a: Expr[Float32], b: Expr[Float32]): Expr[Float32] =
        Expr.BinOp("/", boxed(a), boxed(b))

    ///
    /// `vec3 - vec3` — vector subtraction.
    ///
    pub def subV3(a: Expr[Vec3], b: Expr[Vec3]): Expr[Vec3] =
        Expr.BinOp("-", boxed(a), boxed(b))

    ///
    /// `vec2 - vec2` — vector subtraction.
    ///
    pub def subV2(a: Expr[Vec2], b: Expr[Vec2]): Expr[Vec2] =
        Expr.BinOp("-", boxed(a), boxed(b))

    ///
    /// `a < b`.
    ///
    pub def lt(a: Expr[t], b: Expr[t]): Expr[Bool] =
        Expr.BinOp("<", boxed(a), boxed(b))

    ///
    /// `a > b`.
    ///
    pub def gt(a: Expr[t], b: Expr[t]): Expr[Bool] =
        Expr.BinOp(">", boxed(a), boxed(b))

    ///
    /// `a <= b`.
    ///
    pub def lte(a: Expr[t], b: Expr[t]): Expr[Bool] =
        Expr.BinOp("<=", boxed(a), boxed(b))

    ///
    /// `a >= b`.
    ///
    pub def gte(a: Expr[t], b: Expr[t]): Expr[Bool] =
        Expr.BinOp(">=", boxed(a), boxed(b))

    ///
    /// `a == b`.
    ///
    pub def eq(a: Expr[t], b: Expr[t]): Expr[Bool] =
        Expr.BinOp("==", boxed(a), boxed(b))

    ///
    /// `a != b`.
    ///
    pub def neq(a: Expr[t], b: Expr[t]): Expr[Bool] =
        Expr.BinOp("!=", boxed(a), boxed(b))

    ///
    /// `a && b`.
    ///
    pub def andB(a: Expr[Bool], b: Expr[Bool]): Expr[Bool] =
        Expr.BinOp("&&", boxed(a), boxed(b))

    ///
    /// `a || b`.
    ///
    pub def orB(a: Expr[Bool], b: Expr[Bool]): Expr[Bool] =
        Expr.BinOp("||", boxed(a), boxed(b))

    ///
    /// `!a`.
    ///
    pub def notB(a: Expr[Bool]): Expr[Bool] =
        Expr.UnOp("!", boxed(a))

    ///
    /// Marker trait restricting `any`/`all`/`not` to bool-vector phantoms.
    ///
    /// The three GLSL builtins emit identical code shapes for `bvec2/3/4`,
    /// so a single empty trait gates the dispatch — no per-type method
    /// bodies, no `with` constraint duplicated across families.
    ///
    pub trait IsBVec[t]
    instance IsBVec[BVec2]
    instance IsBVec[BVec3]
    instance IsBVec[BVec4]

    ///
    /// `any(bvecN)`.
    ///
    pub def anyBVec(x: Expr[t]): Expr[Bool] with IsBVec[t] =
        Expr.App("any", List#{boxed(x)})

    ///
    /// `all(bvecN)`.
    ///
    pub def allBVec(x: Expr[t]): Expr[Bool] with IsBVec[t] =
        Expr.App("all", List#{boxed(x)})

    ///
    /// `not(bvecN)`.
    ///
    pub def notBVec(x: Expr[t]): Expr[t] with IsBVec[t] =
        Expr.App("not", List#{boxed(x)})

    ///
    /// `transpose(m)` — matrix transpose.
    ///
    pub def transpose(m: Expr[t]): Expr[t] =
        Expr.App("transpose", List#{boxed(m)})

    ///
    /// `inverse(m)` — matrix inverse.
    ///
    pub def inverse(m: Expr[t]): Expr[t] =
        Expr.App("inverse", List#{boxed(m)})

    ///
    /// `outerProduct(u, v)` — outer product (creates matrix from two vectors).
    ///
    pub def outerProduct(u: Expr[t], v: Expr[t]): Expr[t] =
        Expr.App("outerProduct", List#{boxed(u), boxed(v)})

    ///
    /// `textureQueryLod(sampler, coord)` — returns vec2(mipLevel, numMips).
    ///
    pub def textureQueryLod(sampler: Expr[s], coord: Expr[c]): Expr[Glsl.Types.Vec2] =
        Expr.App("textureQueryLod", List#{boxed(sampler), boxed(coord)})

    ///
    /// `fwidth(x)` — filter width of x in screen space (magnitude of gradient).
    ///
    pub def fwidth(x: Expr[t]): Expr[t] =
        Expr.App("fwidth", List#{boxed(x)})

    ///
    /// `dFdx(x)` — partial derivative with respect to x screen coordinate.
    ///
    pub def dFdx(x: Expr[t]): Expr[t] =
        Expr.App("dFdx", List#{boxed(x)})

    ///
    /// `dFdy(x)` — partial derivative with respect to y screen coordinate.
    ///
    pub def dFdy(x: Expr[t]): Expr[t] =
        Expr.App("dFdy", List#{boxed(x)})

    ///
    /// `a & b` — bitwise AND.
    ///
    pub def bitAnd(a: Expr[t], b: Expr[t]): Expr[t] =
        Expr.BinOp("&", boxed(a), boxed(b))

    ///
    /// `a | b` — bitwise OR.
    ///
    pub def bitOr(a: Expr[t], b: Expr[t]): Expr[t] =
        Expr.BinOp("|", boxed(a), boxed(b))

    ///
    /// `a ^ b` — bitwise XOR.
    ///
    pub def bitXor(a: Expr[t], b: Expr[t]): Expr[t] =
        Expr.BinOp("^", boxed(a), boxed(b))

    ///
    /// `~a` — bitwise NOT.
    ///
    pub def bitNot(a: Expr[t]): Expr[t] =
        Expr.UnOp("~", boxed(a))

    ///
    /// `a << n` — bitwise left shift.
    ///
    pub def lshift(a: Expr[t], n: Expr[Int32]): Expr[t] =
        Expr.BinOp("<<", boxed(a), boxed(n))

    ///
    /// `fma(a, b, c)` — fused multiply-add: a*b + c.
    ///
    pub def fma(a: Expr[t], b: Expr[t], c: Expr[t]): Expr[t] =
        Expr.App("fma", List#{boxed(a), boxed(b), boxed(c)})

    ///
    /// Generic type cast: `cast(e): Expr[b]`.
    /// Renders as the expression wrapped in parentheses.
    ///
    pub def cast(e: Expr[a]): Expr[b] =
        Expr.App("", List#{boxed(e)})

    ///
    /// Type cast to uint: `uint(e)`.
    ///
    pub def asUint(e: Expr[t]): Expr[Int32] =
        Expr.App("uint", List#{boxed(e)})

    ///
    /// Type cast to int: `int(e)`.
    ///
    pub def asInt(e: Expr[t]): Expr[Int32] =
        Expr.App("int", List#{boxed(e)})

    ///
    /// Type cast to float: `float(e)`.
    ///
    pub def asFloat(e: Expr[t]): Expr[Float32] =
        Expr.App("float", List#{boxed(e)})

    ///
    /// Type cast to bool: `bool(e)`.
    ///
    pub def asBool(e: Expr[t]): Expr[Bool] =
        Expr.App("bool", List#{boxed(e)})

    ///
    /// Generic function call: `name(args...)`.
    ///
    pub def call(name: String, args: List[RenderedExpr]): Expr[t] =
        Expr.App(name, args)
}
