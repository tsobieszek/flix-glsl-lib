///
/// `Glsl.Expr` — typed GLSL expression AST.
///
/// `Expr[t]` is a phantom-typed wrapper around a unified `Ast`. The `t` parameter
/// is phantom — Flix uses it to keep the host typed; it carries no runtime witness.
/// Codegen is a single fold over the AST tree (`render`).
///
/// All constructors are accessible (the AST is meant to be inspected by
/// later passes: inlining, constant folding, dead-code elimination), but
/// users should reach for the smart constructors in `Glsl.Smart` to build
/// shaders.
///
pub mod Glsl.Expr {

    ///
    /// Typed GLSL expression. The `t` parameter is phantom — it carries no
    /// runtime witness, only compile-time type information for phantom-type
    /// dispatch (e.g., `let x: Expr[Vec3] = ...`).
    ///
    pub enum Expr[_t] with Eq {
        case Of(Ast)
    }

    ///
    /// Untyped expression AST — the core representation.
    ///
    pub enum Ast with Eq {
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
        case BinOp(String, Ast, Ast)

        ///
        /// Unary operator. The operator string is GLSL syntax (`"-"`,
        /// `"!"`, ...). Render wraps the result in parentheses.
        ///
        case UnOp(String, Ast)

        ///
        /// Function application: `name(args...)`. Used for both builtins
        /// (`sin(x)`, `vec3(a,b,c)`) and user functions.
        ///
        case App(String, Vector[Ast])

        ///
        /// Field / swizzle access: `e.xy`, `e.rgb`, `m[0].xyz`, etc. The
        /// second argument is the post-dot string verbatim.
        ///
        case Field(Ast, String)

        ///
        /// Array indexing: `arr[i]`.
        ///
        case Index(Ast, Ast)
    }

    ///
    /// Rendering an `Ast` to a GLSL fragment.
    ///
    pub def render(a: Ast): String = match a {
        case Ast.Lit(s)               => s
        case Ast.Var(name)            => name
        case Ast.BinOp(op, l, r)      => "(${render(l)} ${op} ${render(r)})"
        case Ast.UnOp(op, e1)         => "(${op}${render(e1)})"
        case Ast.App(name, args)      => "${name}(${joinArgs(args)})"
        case Ast.Field(child, suffix) => "${render(child)}.${suffix}"
        case Ast.Index(child, idx)    => "${render(child)}[${render(idx)}]"
    }

    ///
    /// Erases the phantom type from a typed expression.
    ///
    pub def erase(e: Expr[_t]): Ast = match e {
        case Expr.Of(a) => a
    }

    ///
    /// Renders a typed expression.
    ///
    pub def renderExpr(e: Expr[_t]): String = render(erase(e))

    ///
    /// Boxes a typed expression for use as a child of another expression.
    /// Now returns an untyped `Ast`.
    ///
    pub def boxed(e: Expr[_t]): Ast = erase(e)

    ///
    /// Unwraps and renders an AST child fragment.
    ///
    pub def unbox(a: Ast): String = render(a)

    def joinArgs(args: Vector[Ast]): String =
        args |> Vector.map(render) |> Vector.join(", ")

    instance ToString[Expr[t]] {
        pub def toString(e: Expr[t]): String = renderExpr(e)
    }
}
