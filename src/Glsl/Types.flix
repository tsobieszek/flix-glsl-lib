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
    /// Maps a Flix type-token to its GLSL type name.
    ///
    /// The `Proxy[t]` parameter is how we route trait dispatch when there
    /// is no value of type `t` available at the call site; it serves as an
    /// explicit witness for the compiler.
    ///
    pub trait GlslType[t] {
        pub def typeName(p: Proxy[t]): String
    }

    instance GlslType[Int32] {
        pub def typeName(_p: Proxy[Int32]): String = "int"
    }

    instance GlslType[Float32] {
        pub def typeName(_p: Proxy[Float32]): String = "float"
    }

    instance GlslType[Bool] {
        pub def typeName(_p: Proxy[Bool]): String = "bool"
    }

    instance GlslType[Vec2] {
        pub def typeName(_p: Proxy[Vec2]): String = "vec2"
    }

    instance GlslType[Vec3] {
        pub def typeName(_p: Proxy[Vec3]): String = "vec3"
    }

    instance GlslType[Vec4] {
        pub def typeName(_p: Proxy[Vec4]): String = "vec4"
    }

    instance GlslType[IVec2] {
        pub def typeName(_p: Proxy[IVec2]): String = "ivec2"
    }

    instance GlslType[IVec3] {
        pub def typeName(_p: Proxy[IVec3]): String = "ivec3"
    }

    instance GlslType[IVec4] {
        pub def typeName(_p: Proxy[IVec4]): String = "ivec4"
    }

    instance GlslType[UVec2] {
        pub def typeName(_p: Proxy[UVec2]): String = "uvec2"
    }

    instance GlslType[UVec3] {
        pub def typeName(_p: Proxy[UVec3]): String = "uvec3"
    }

    instance GlslType[UVec4] {
        pub def typeName(_p: Proxy[UVec4]): String = "uvec4"
    }

    instance GlslType[UInt32] {
        pub def typeName(_p: Proxy[UInt32]): String = "uint"
    }

    instance GlslType[BVec2] {
        pub def typeName(_p: Proxy[BVec2]): String = "bvec2"
    }

    instance GlslType[BVec3] {
        pub def typeName(_p: Proxy[BVec3]): String = "bvec3"
    }

    instance GlslType[BVec4] {
        pub def typeName(_p: Proxy[BVec4]): String = "bvec4"
    }

    instance GlslType[Mat2] {
        pub def typeName(_p: Proxy[Mat2]): String = "mat2"
    }

    instance GlslType[Mat3] {
        pub def typeName(_p: Proxy[Mat3]): String = "mat3"
    }

    instance GlslType[Mat4] {
        pub def typeName(_p: Proxy[Mat4]): String = "mat4"
    }

    instance GlslType[Sampler2D] {
        pub def typeName(_p: Proxy[Sampler2D]): String = "sampler2D"
    }

    instance GlslType[SamplerCube] {
        pub def typeName(_p: Proxy[SamplerCube]): String = "samplerCube"
    }

    instance GlslType[Sampler2DArray] {
        pub def typeName(_p: Proxy[Sampler2DArray]): String = "sampler2DArray"
    }

    instance GlslType[Sampler3D] {
        pub def typeName(_p: Proxy[Sampler3D]): String = "sampler3D"
    }

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
