# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in this directory.

## What this project is

`flix` is a Flix implementation of a GLSL ES 300 and GLSL 420 shader DSL. Shader expressions are represented as a typed AST, declarations are emitted through a `Build` effect, and `src/Examples/ShaderTest.flix` is the de-facto integration test.

Toolchain: Flix 0.72.0 (`/usr/bin/flix`).

## Build, run, check, test

- `cd flix`
- `flix check` - type-check the whole project.
- `flix test` - test the whole project.
- `flix run` - print the vertex/fragment GLSL plus the variants table.

`flix.toml` already configures the project; no extra dependencies are required for the current prototype.

## Architecture

### Core pieces

1. `src/Glsl/Expr.flix` - `Expr[t]` AST plus render fold.
2. `src/Glsl/Build.flix` - `eff Build`, the handler, and `ShaderSource`.
3. `src/Glsl/Smart.flix` - smart constructors for uniforms, attributes, varyings, outputs, assignments, and locals.
4. `src/Glsl/Stage.flix` - `Stage`.
5. `src/Glsl/Types.flix` - phantom Vec/Mat tags and `GlslType`.
6. `src/Glsl/Builtin.flix` - builtins and constructors.
7. `src/Glsl/Numeric.flix` - numeric traits for same-type arithmetic.
8. `src/Glsl/Swizzle.flix` - typed swizzle helpers.
9. `src/Glsl/Render.flix` - `ShaderSource` to stage-specific GLSL string.
10. `src/Glsl/Variants.flix` - parameter enumeration and dispatch.
11. `src/Main.flix` - entry point of a sample shader.
12. `src/Examples.flix` and `src/Examples/ShaderTest.flix` - example module and integration shader.

### Module layout

```
flix.toml
src/
    Main.flix
    Glsl.flix
    Glsl/
        Types.flix
        Expr.flix
        Build.flix
        Stage.flix
        Smart.flix
        Swizzle.flix
        Builtin.flix
        Numeric.flix
        Render.flix
        Variants.flix
    Examples.flix
    Examples/ShaderTest.flix
```

### Design notes

- Declarations are emitted on first reference, so dead declarations never need a cleanup pass.
- Keep `Build` monomorphic by passing rendered strings through the effect.
- One function per builtin family is usually enough; when GLSL names collide by shape, use distinct helper names.
- `uvec*` constructors should accept `Expr[Int32]` arguments and use a helper that renders the GLSL `u` suffix.
- Use explicit type ascription or `Proxy[t]` when the target GLSL type cannot be inferred.
- Empty marker traits are the right tool for closed phantom families such as bool vectors.
- `captureBody` is the preferred pattern when a nested shader block should intercept statements while forwarding declarations.
- Keep helper names away from reserved words. `modF`, `discardFrag`, and `att` are good examples.

### Layout gotchas

1. `src/Glsl.flix` is required as the parent module file for `src/Glsl/...` modules.
2. The file basename must match the module's leaf name.
3. Companion declarations must be the first declaration inside their module.
4. Empty enum bodies are illegal, so phantom types need a constructor such as `case Tag`.

### Current implementation shape

- `uniformWithBinding`, `uniformWithPrecision`, and `uniformWithLayoutAndPrecision` show the preferred `Option`-driven pattern for optional qualifiers.
- `declareUniformBlockMember` reuses the function declaration channel for interface blocks. That keeps the implementation simple; a dedicated block channel can come later if ordering needs to be stricter.
- Nested handlers via `captureBody` are already in use and should stay that way unless the effect story changes.
- `src/Examples/ShaderTest.flix` is the end-to-end shader example to keep green.

### Type system and phantom types

The type parameter `t` in `Expr[t]` is **phantom** — it carries no runtime value, only compile-time information. This enables:
- `let mvp: Expr[Mat4] = uniform("mvp")` — type-checked at compile time; same JVM representation as any other Expr.
- `mul(v: Expr[Vec3], s: Expr[Float32]): Expr[Vec3]` — prevents Vec2 + Float32 errors.
- Proxy[t] pattern used when no value of type t is available: `GlslType.typeName((Proxy.Proxy: Proxy[Mat4]))`.

When extending the type system, reuse the phantom enum pattern: tag constructor, no payload, `with Eq` constraint.

### Monomorphic Build effect

The `Build` effect channels accept pre-rendered **String**, not polymorphic `Expr[t]`. This design:
- Avoids Flix 0.72.0 polymorphic effect limitations.
- Forces rendering at smart constructor time (e.g., uniform() returns already-rendered "uniform mat4 mvp;").
- Trade-off: loses AST fidelity for optimization (inlining, constant folding) but simplifies accumulation.

If a future Flix version supports polymorphic effects cleanly, consider passing unrendered Expr through channels.

### Data flow summary

User code → Smart.uniform/assign/etc. → Build effect → MutList accumulation (in region) → ShaderSource (frozen Vector) → Render.renderStage → GLSL string. No mutable references; all state is region-scoped.

### Module dependencies

- **Types.flix** (no deps) — foundation; provides phantom tags and GlslType trait.
- **Expr.flix** (no deps) — AST; standalone render fold.
- **Build.flix** (no deps) — effect definition; uses only Flix stdlib.
- **Smart.flix** → Build, Expr, Types, Builtin — user-facing API.
- **Builtin.flix** → Expr, Types — GLSL builtins and constructors.
- **Swizzle.flix** → Expr, Types — typed swizzle helpers.
- **Numeric.flix** → Expr, Types — arithmetic trait instances.
- **Render.flix** → Build, Stage — final GLSL output.
- **Variants.flix** → Build, Render — parameter enumeration.

Clean layering: Types and Expr are bottom; Build sits above (uses them); Smart sits on top (composes Expr, Build, Builtin).

### Stage-conditional rendering

`renderStage(stage, src)` omits stage-irrelevant sections:
- **Vertex:** includes attributes, omits outputs, omits precision declaration.
- **Fragment:** includes outputs and "precision highp float", omits attributes.

This automatic elision eliminates dead code without requiring separate vertex/fragment accumulation. Same ShaderSource works for both stages.

### Additional docs:

- `FLIX-SKILL.md` contains info about Flix usage, always read it in
- `ADDITIONAL_INSIGHTS.md` more insights about the code base and design rationale
- `IMPLEMENTING_PARSER.md` guidance for adding the GLSL parser
- `codebase_analysis.md` comprehensive codebase documentation (9 sections)
