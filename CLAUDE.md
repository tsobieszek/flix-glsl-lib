# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in this directory.

## What this project is

`flix` is a Flix implementation of a GLSL ES 300 and GLSL 420 shader DSL. Shader expressions, declarations, statements, and blocks are represented as typed AST nodes and accumulated through a `Build` effect.

Toolchain: Flix 0.72.0 (`/usr/bin/flix`).

## Build, run, check, test

- `cd flix`
- `flix check` - type-check the whole project.
- `flix test` - test the whole project.
- `flix run` - print the vertex/fragment GLSL plus the variants table.

`flix.toml` already configures the project; no extra dependencies are required for the current prototype.

## Architecture

### Core pieces

1. `src/Glsl/Expr.flix` - `Expr[t]` expression AST plus render fold.
2. `src/Glsl/Ast.flix` - AST for declarations, statements, and render helpers.
3. `src/Glsl/Build.flix` - `eff Build`, the handler, and `ShaderSource`.
4. `src/Glsl/Smart.flix` - smart constructors for uniforms, attributes, varyings, outputs, locals/consts/globals, structs, interface blocks, uniform blocks, Vulkan descriptors (set/binding), SSBOs, push constants, control flow, user-defined functions, preprocessor macros, and comments.
5. `src/Glsl/Stage.flix` - `Stage`.
6. `src/Glsl/Types.flix` - phantom Vec/Mat tags and `GlslType`.
7. `src/Glsl/Builtin.flix` - builtins and constructors.
8. `src/Glsl/Numeric.flix` - numeric traits for same-type arithmetic.
9. `src/Glsl/Swizzle.flix` - typed swizzle helpers.
10. `src/Glsl/Render.flix` - `ShaderSource` to stage-specific GLSL string; two targets: `renderStage` (GLSL ES 300) and `renderStage420` (GLSL 4.20 core).
11. `src/Glsl/Variants.flix` - parameter enumeration and dispatch.

### Module layout

```
flix.toml
src/
    Glsl.flix
    Glsl/
        Types.flix
        Expr.flix
        Ast.flix
        Build.flix
        Stage.flix
        Smart.flix
        Swizzle.flix
        Builtin.flix
        Numeric.flix
        Render.flix
        Variants.flix
```

### Design notes

- Declarations are emitted on first reference, so dead declarations never need a cleanup pass.
- `Build` carries typed AST payloads; keep rendering centralized in `Glsl.Ast` and `Glsl.Render`.
- One function per builtin family is usually enough; when GLSL names collide by shape, use distinct helper names.
- `uvec*` constructors should accept `Expr[Int32]` arguments and use a helper that renders the GLSL `u` suffix.
- Use explicit type ascription or `Proxy[t]` when the target GLSL type cannot be inferred.
- Empty marker traits are the right tool for closed phantom families such as bool vectors.
- `captureBody` is the preferred pattern when a nested shader block should intercept statements while forwarding declarations.
- `captureMembers` is the matching helper for struct/interface/uniform-block members; it intercepts `emitMember` and forwards declarations/statements.
- Keep helper names away from reserved words. `modF`, `discardFrag`, and `att` are good examples.

### Layout gotchas

1. `src/Glsl.flix` is required as the parent module file for `src/Glsl/...` modules.
2. The file basename must match the module's leaf name.
3. Companion declarations must be the first declaration inside their module.
4. Empty enum bodies are illegal, so phantom types need a constructor such as `case Tag`.

### Current implementation shape

- `uniformWithBinding`, `uniformWithPrecision`, and `uniformWithLayoutAndPrecision` show the preferred `Option`-driven pattern for optional qualifiers.
- Top-level declarations are represented as `Glsl.Ast.TopLevel` values and emitted via `Build.declTopLevel`.
- Nested handlers via `captureBody` are already in use and should stay that way unless the effect story changes.

### Type system and phantom types

The type parameter `t` in `Expr[t]` is **phantom** — it carries no runtime value, only compile-time information. This enables:
- `let mvp: Expr[Mat4] = uniform("mvp")` — type-checked at compile time; same JVM representation as any other Expr.
- `mul(v: Expr[Vec3], s: Expr[Float32]): Expr[Vec3]` — prevents Vec2 + Float32 errors.
- `Proxy[t]` pattern used when no value of type t is available: `GlslType.typeRef((Proxy.Proxy: Proxy[Mat4]))`; `Glsl.Types.typeName` is derived from that when a string spelling is needed.
- Proxy convenience constants (`vec3Ty()`, `mat4Ty()`, `sampler2DTy()`, etc.) avoid writing `(Proxy.Proxy: Proxy[X])` at call sites — use them.

When extending the type system, reuse the phantom enum pattern: tag constructor, no payload, `with Eq` constraint.

### Typed AST Build Effect

The `Build` effect channels accept structured payloads from `Glsl.Ast`: `Preprocessor`, `Uniform`, `Attribute`, `Varying`, `Output`, `TopLevel`, `Global`, `Stmt`, and `BlockMember`. This design:
- Keeps declarations, statements, and expression children inspectable after `runBuild`.
- Lets tests assert on AST shape instead of only string fragments.
- Makes the future parser target clear: construct a `ShaderSource` directly, then call `Render.renderStage`.

Rendering should happen in `Glsl.Ast.render*` helpers and `Glsl.Render`, not inside smart constructors.

### Data flow summary

User code → Smart.uniform/assign/etc. → typed `Build` effect → MutList accumulation (in region) → `ShaderSource` of AST vectors → `Render.renderStage` → GLSL string. No mutable references; all state is region-scoped.

### Module dependencies

- **Types.flix** (no deps) — foundation; provides phantom tags and GlslType trait.
- **Expr.flix** (no deps) — expression AST; standalone render fold.
- **Ast.flix** → Types, Expr — declaration, statement, block AST and render helpers.
- **Build.flix** → Ast — effect definition, `ShaderSource`, `captureBody`, `captureMembers`.
- **Smart.flix** → Build, Ast, Expr, Types, Builtin — user-facing API.
- **Builtin.flix** → Expr, Types — GLSL builtins and constructors.
- **Swizzle.flix** → Expr, Types — typed swizzle helpers.
- **Numeric.flix** → Expr, Types — arithmetic trait instances.
- **Render.flix** → Build, Ast, Stage — final GLSL output.
- **Variants.flix** → Build, Render — parameter enumeration.

Clean layering: Types and Expr are bottom; Ast references both; Build sits above Ast; Smart sits on top and composes Expr, Ast, Build, and Builtin.

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
