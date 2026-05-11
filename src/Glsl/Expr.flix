///
/// `Glsl.Expr` — typed GLSL expression AST.
///
/// `Expr[t]` is a phantom-typed tree of the GLSL fragment that produces a
/// value of type `t`. Codegen is a single fold over the tree (`render`).
///
/// All constructors are accessible (the AST is meant to be inspected by
/// later passes: inlining, constant folding, dead-code elimination), but
/// users should reach for the smart constructors in `Glsl.Smart` to build
/// shaders.
///
pub mod Glsl.Expr {

    ///
    /// Typed GLSL expression. The `t` parameter is phantom — Flix uses it
    /// to keep the host typed; it carries no runtime witness on its own.
    ///
    pub enum Expr[_t] with Eq {
        ///
        /// Literal already rendered to a GLSL fragment, e.g. `"1.0"` or
        /// `"true"`. Use `lit*` smart constructors to create these.
        ///
        case Lit(String)

        ///
        /// Reference to a GLSL identifier (uniform / attribute / varying /
        /// output / local).
        ///
        case Var(String)

        ///
        /// Binary operator. The operator string is GLSL syntax (`"+"`,
        /// `"*"`, ...). Render wraps the result in parentheses.
        ///
        case BinOp(String, RenderedExpr, RenderedExpr)

        ///
        /// Unary operator. The operator string is GLSL syntax (`"-"`,
        /// `"!"`, ...). Render wraps the result in parentheses.
        ///
        case UnOp(String, RenderedExpr)

        ///
        /// Function application: `name(args...)`. Used for both builtins
        /// (`sin(x)`, `vec3(a,b,c)`) and user functions.
        ///
        case App(String, List[RenderedExpr])

        ///
        /// Field / swizzle access: `e.xy`, `e.rgb`, `m[0].xyz`, etc. The
        /// second argument is the post-dot string verbatim.
        ///
        case Field(RenderedExpr, String)

        ///
        /// Array indexing: `arr[i]`.
        ///
        case Index(RenderedExpr, RenderedExpr)
    }

    ///
    /// Boxed, type-erased expression. Children of an `Expr[t]` may have
    /// different types (e.g. `vec3(a, b, c)` mixes `Float32` arguments
    /// inside a `Vec3` parent), and Flix does not allow heterogeneously
    /// typed lists. `RenderedExpr` is a wrapper that carries the already-
    /// rendered string for child positions.
    ///
    /// In a more elaborate AST, this would be `case Heterogeneous(Vector[ExistsT])`
    /// with an existential — but that machinery is not worth carrying for a
    /// shader DSL whose interpretations are all "fold to string". Pre-
    /// rendering during construction loses fidelity for inlining/folding
    /// passes; a future iteration that wants those passes should switch
    /// to a uniformly-typed boxing wrapper instead.
    ///
    pub enum RenderedExpr with Eq {
        case R(String)
    }

    ///
    /// Rendering a top-level `Expr[t]` to a GLSL fragment.
    ///
    pub def render(e: Expr[t]): String = match e {
        case Expr.Lit(s)               => s
        case Expr.Var(name)            => name
        case Expr.BinOp(op, l, r)      => "(${unbox(l)} ${op} ${unbox(r)})"
        case Expr.UnOp(op, e1)         => "(${op}${unbox(e1)})"
        case Expr.App(name, args)      => "${name}(${joinArgs(args)})"
        case Expr.Field(child, suffix) => "${unbox(child)}.${suffix}"
        case Expr.Index(child, idx)    => "${unbox(child)}[${unbox(idx)}]"
    }

    ///
    /// Boxes a typed expression for use as a child of another expression.
    ///
    pub def boxed(e: Expr[t]): RenderedExpr =
        RenderedExpr.R(render(e))

    ///
    /// Unwraps an already-rendered child fragment.
    ///
    pub def unbox(r: RenderedExpr): String = match r {
        case RenderedExpr.R(s) => s
    }

    def joinArgs(args: List[RenderedExpr]): String =
        args |> List.map(unbox) |> List.join(", ")

    instance ToString[Expr[t]] {
        pub def toString(e: Expr[t]): String = render(e)
    }
}
