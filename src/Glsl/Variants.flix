///
/// `Glsl.Variants` — parameter enumeration for shader variants.
///
/// Pass in the parameter ranges and a builder that takes a `ParamCombo`,
/// get back a vector of all combinations with their generated GLSL at
/// runtime. No source generation, no reflection.
///
pub mod Glsl.Variants {

    use Glsl.Build.runBuild
    use Glsl.Build.Build
    use Glsl.Render.renderStage
    use Glsl.Stage.Stage

    ///
    /// A flag is named, takes one of two boolean values; an int range
    /// is named, takes a value in `[lo, hi]`. Together they reproduce
    /// the kapt processor's enumeration domain.
    ///
    pub enum Param with Eq, Order, ToString {
        case Flag(String, Bool)
        case Int(String, Int32)
    }

    pub type alias ParamCombo = Vector[Param]

    pub type alias VariantSources = {
        vertex = String,
        fragment = String
    }

    ///
    /// Cartesian product over the parameter spec, producing every
    /// `ParamCombo` and the `(vertex, fragment)` GLSL it generates.
    ///
    /// `spec` describes one parameter axis at a time: `Flag` for a
    /// bool toggle and `Int(lo, hi)` for a discrete range. `runShader`
    /// is the user's stage builder, parameterised over the combo.
    ///
    pub def enumerate(
        spec: List[ParamSpec],
        runShader: ParamCombo -> Stage -> Unit \ Build
    ): Vector[(ParamCombo, VariantSources)] =
        expand(spec)
        |> List.map(combo -> {
            let vSrc = renderStage(Stage.Vertex,   runBuild(_ -> runShader(combo)(Stage.Vertex)));
            let fSrc = renderStage(Stage.Fragment, runBuild(_ -> runShader(combo)(Stage.Fragment)));
            (combo, { vertex = vSrc, fragment = fSrc })
        })
        |> List.toVector

    ///
    /// One axis of variation: a flag or an int range.
    ///
    pub enum ParamSpec with Eq, ToString {
        case FlagSpec(String)
        case IntSpec(String, Int32, Int32)
    }

    def expand(spec: List[ParamSpec]): List[ParamCombo] = match spec {
        case Nil           => List#{Vector#{}}
        case head :: tail  =>
            let rest = expand(tail);
            let heads = expandOne(head);
            heads |> List.flatMap(p ->
                rest |> List.map(combo -> Vector.append(Vector#{p}, combo))
            )
    }

    def expandOne(s: ParamSpec): List[Param] = match s {
        case ParamSpec.FlagSpec(name)        =>
            List#{Param.Flag(name, false), Param.Flag(name, true)}
        case ParamSpec.IntSpec(name, lo, hi) =>
            List.range(lo, hi + 1) |> List.map(i -> Param.Int(name, i))
    }

    ///
    /// Lookup helper: in a `ParamCombo`, find a `Flag(name, _)` value.
    /// Returns `false` if the param isn't present (default behavior).
    ///
    pub def flag(name: String, combo: ParamCombo): Bool =
        combo |> Vector.findMap(p -> match p {
            case Param.Flag(n, v) if n == name => Some(v)
            case _                             => None
        }) |> Option.getWithDefault(false)

    ///
    /// Lookup helper: find an `Int(name, _)` value, defaulting to `0`.
    ///
    pub def intParam(name: String, combo: ParamCombo): Int32 =
        combo |> Vector.findMap(p -> match p {
            case Param.Int(n, v) if n == name => Some(v)
            case _                            => None
        }) |> Option.getWithDefault(0)
}
