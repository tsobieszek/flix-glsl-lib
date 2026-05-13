///
/// `Glsl.Types` — phantom type tags for GLSL primitive types and the
/// `GlslType` trait that maps a Flix type-token to its GLSL spelling.
///
/// The tag enums (`Vec2`, `Vec3`, ...) carry no runtime payload; they exist
/// only so the type checker can disambiguate which `GlslType` instance to
/// pick. Float32 / Bool reuse the Flix builtins directly.
///
pub mod Glsl.Types {

    ///
    /// GLSL type reference — the primary representation of a type in the AST.
    ///
    pub enum TypeRef with Eq, ToString {
        case Float
        case Int
        case UInt
        case Bool
        case Void
        case Vec2
        case Vec3
        case Vec4
        case IVec2
        case IVec3
        case IVec4
        case UVec2
        case UVec3
        case UVec4
        case BVec2
        case BVec3
        case BVec4
        case Mat2
        case Mat3
        case Mat4
        case Sampler2D
        case SamplerCube
        case Sampler2DArray
        case Sampler3D
        case Named(String)
        case Array(TypeRef, Int32)
    }

    ///
    /// GLSL precision qualifier: highp, mediump, lowp.
    ///
    pub enum Precision with Eq, ToString {
        case Highp
        case Mediump
        case Lowp
    }

    ///
    /// Render a `TypeRef` to its GLSL spelling.
    ///
    pub def renderTypeRef(t: TypeRef): String = match t {
        case TypeRef.Float => "float"
        case TypeRef.Int => "int"
        case TypeRef.UInt => "uint"
        case TypeRef.Bool => "bool"
        case TypeRef.Void => "void"
        case TypeRef.Vec2 => "vec2"
        case TypeRef.Vec3 => "vec3"
        case TypeRef.Vec4 => "vec4"
        case TypeRef.IVec2 => "ivec2"
        case TypeRef.IVec3 => "ivec3"
        case TypeRef.IVec4 => "ivec4"
        case TypeRef.UVec2 => "uvec2"
        case TypeRef.UVec3 => "uvec3"
        case TypeRef.UVec4 => "uvec4"
        case TypeRef.BVec2 => "bvec2"
        case TypeRef.BVec3 => "bvec3"
        case TypeRef.BVec4 => "bvec4"
        case TypeRef.Mat2 => "mat2"
        case TypeRef.Mat3 => "mat3"
        case TypeRef.Mat4 => "mat4"
        case TypeRef.Sampler2D => "sampler2D"
        case TypeRef.SamplerCube => "samplerCube"
        case TypeRef.Sampler2DArray => "sampler2DArray"
        case TypeRef.Sampler3D => "sampler3D"
        case TypeRef.Named(n) => n
        case TypeRef.Array(elem, _size) => renderTypeRef(elem)
    }

    ///
    /// Render a `Precision` to its GLSL spelling.
    ///
    pub def renderPrecision(p: Precision): String = match p {
        case Precision.Highp => "highp"
        case Precision.Mediump => "mediump"
        case Precision.Lowp => "lowp"
    }

    ///
    /// Phantom GLSL `vec2` tag.
    ///
    pub enum Vec2 with Eq {
        case Tag
    }

    pub enum Vec3 with Eq {
        case Tag
    }

    pub enum Vec4 with Eq {
        case Tag
    }

    pub enum IVec2 with Eq {
        case Tag
    }

    pub enum IVec3 with Eq {
        case Tag
    }

    pub enum IVec4 with Eq {
        case Tag
    }

    pub enum UVec2 with Eq {
        case Tag
    }

    pub enum UVec3 with Eq {
        case Tag
    }

    pub enum UVec4 with Eq {
        case Tag
    }

    pub enum UInt32 with Eq {
        case Tag
    }

    pub enum BVec2 with Eq {
        case Tag
    }

    pub enum BVec3 with Eq {
        case Tag
    }

    pub enum BVec4 with Eq {
        case Tag
    }

    pub enum Mat2 with Eq {
        case Tag
    }

    pub enum Mat3 with Eq {
        case Tag
    }

    pub enum Mat4 with Eq {
        case Tag
    }

    pub enum Sampler2D with Eq {
        case Tag
    }

    pub enum SamplerCube with Eq {
        case Tag
    }

    pub enum Sampler2DArray with Eq {
        case Tag
    }

    pub enum Sampler3D with Eq {
        case Tag
    }
///
/// Phantom GLSL struct tag.
///
pub enum GlslStruct[_t] with Eq {
    case Tag
}

///
/// Phantom GLSL array wrapper. The element type is tracked in the
/// parameter; array size is carried where the declaration is emitted.
///
pub enum GlslArray[_t] with Eq {
    case Tag
}

    ///
    /// Maps a Flix type-token to its GLSL type reference.
    ///
    /// The `Proxy[t]` parameter is how we route trait dispatch when there
    /// is no value of type `t` available at the call site; it serves as an
    /// explicit witness for the compiler.
    ///
    pub trait GlslType[t] {
        pub def typeRef(p: Proxy[t]): TypeRef
    }

    instance GlslType[Int32] {
        pub def typeRef(_p: Proxy[Int32]): TypeRef = TypeRef.Int
    }

    instance GlslType[Float32] {
        pub def typeRef(_p: Proxy[Float32]): TypeRef = TypeRef.Float
    }

    instance GlslType[Bool] {
        pub def typeRef(_p: Proxy[Bool]): TypeRef = TypeRef.Bool
    }

    instance GlslType[Vec2] {
        pub def typeRef(_p: Proxy[Vec2]): TypeRef = TypeRef.Vec2
    }

    instance GlslType[Vec3] {
        pub def typeRef(_p: Proxy[Vec3]): TypeRef = TypeRef.Vec3
    }

    instance GlslType[Vec4] {
        pub def typeRef(_p: Proxy[Vec4]): TypeRef = TypeRef.Vec4
    }

    instance GlslType[IVec2] {
        pub def typeRef(_p: Proxy[IVec2]): TypeRef = TypeRef.IVec2
    }

    instance GlslType[IVec3] {
        pub def typeRef(_p: Proxy[IVec3]): TypeRef = TypeRef.IVec3
    }

    instance GlslType[IVec4] {
        pub def typeRef(_p: Proxy[IVec4]): TypeRef = TypeRef.IVec4
    }

    instance GlslType[UVec2] {
        pub def typeRef(_p: Proxy[UVec2]): TypeRef = TypeRef.UVec2
    }

    instance GlslType[UVec3] {
        pub def typeRef(_p: Proxy[UVec3]): TypeRef = TypeRef.UVec3
    }

    instance GlslType[UVec4] {
        pub def typeRef(_p: Proxy[UVec4]): TypeRef = TypeRef.UVec4
    }

    instance GlslType[UInt32] {
        pub def typeRef(_p: Proxy[UInt32]): TypeRef = TypeRef.UInt
    }

    instance GlslType[BVec2] {
        pub def typeRef(_p: Proxy[BVec2]): TypeRef = TypeRef.BVec2
    }

    instance GlslType[BVec3] {
        pub def typeRef(_p: Proxy[BVec3]): TypeRef = TypeRef.BVec3
    }

    instance GlslType[BVec4] {
        pub def typeRef(_p: Proxy[BVec4]): TypeRef = TypeRef.BVec4
    }

    instance GlslType[Mat2] {
        pub def typeRef(_p: Proxy[Mat2]): TypeRef = TypeRef.Mat2
    }

    instance GlslType[Mat3] {
        pub def typeRef(_p: Proxy[Mat3]): TypeRef = TypeRef.Mat3
    }

    instance GlslType[Mat4] {
        pub def typeRef(_p: Proxy[Mat4]): TypeRef = TypeRef.Mat4
    }

    instance GlslType[Sampler2D] {
        pub def typeRef(_p: Proxy[Sampler2D]): TypeRef = TypeRef.Sampler2D
    }

    instance GlslType[SamplerCube] {
        pub def typeRef(_p: Proxy[SamplerCube]): TypeRef = TypeRef.SamplerCube
    }

    instance GlslType[Sampler2DArray] {
        pub def typeRef(_p: Proxy[Sampler2DArray]): TypeRef = TypeRef.Sampler2DArray
    }

    instance GlslType[Sampler3D] {
        pub def typeRef(_p: Proxy[Sampler3D]): TypeRef = TypeRef.Sampler3D
    }

    ///
    /// Get the GLSL type name from a Flix type-token.
    /// Derives from `typeRef` for a single source of truth.
    ///
    pub def typeName(p: Proxy[t]): String with GlslType[t] =
        renderTypeRef(GlslType.typeRef(p))

    ///
    /// Convenience proxy constants — saves writing `(Proxy.Proxy: Proxy[X])`
    /// at every call site.
    ///
    pub def intTy(): Proxy[Int32] = Proxy.Proxy
    pub def floatTy(): Proxy[Float32] = Proxy.Proxy
    pub def boolTy(): Proxy[Bool] = Proxy.Proxy
    pub def vec2Ty(): Proxy[Vec2] = Proxy.Proxy
    pub def vec3Ty(): Proxy[Vec3] = Proxy.Proxy
    pub def vec4Ty(): Proxy[Vec4] = Proxy.Proxy
    pub def ivec2Ty(): Proxy[IVec2] = Proxy.Proxy
    pub def ivec3Ty(): Proxy[IVec3] = Proxy.Proxy
    pub def ivec4Ty(): Proxy[IVec4] = Proxy.Proxy
    pub def uvec2Ty(): Proxy[UVec2] = Proxy.Proxy
    pub def uvec3Ty(): Proxy[UVec3] = Proxy.Proxy
    pub def uvec4Ty(): Proxy[UVec4] = Proxy.Proxy
    pub def uintTy(): Proxy[UInt32] = Proxy.Proxy
    pub def bvec2Ty(): Proxy[BVec2] = Proxy.Proxy
    pub def bvec3Ty(): Proxy[BVec3] = Proxy.Proxy
    pub def bvec4Ty(): Proxy[BVec4] = Proxy.Proxy
    pub def mat2Ty(): Proxy[Mat2] = Proxy.Proxy
    pub def mat3Ty(): Proxy[Mat3] = Proxy.Proxy
    pub def mat4Ty(): Proxy[Mat4] = Proxy.Proxy
    pub def sampler2DTy(): Proxy[Sampler2D] = Proxy.Proxy
    pub def samplerCubeTy(): Proxy[SamplerCube] = Proxy.Proxy
    pub def sampler2DArrayTy(): Proxy[Sampler2DArray] = Proxy.Proxy
    pub def sampler3DTy(): Proxy[Sampler3D] = Proxy.Proxy
}
