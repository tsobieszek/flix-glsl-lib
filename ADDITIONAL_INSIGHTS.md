# Additional insights

Notes kept out of `CLAUDE.md` so that file stays focused.

## Effect system and accumulation

- `src/Glsl/Build.flix` uses an effect handler with 9 typed operations: `declPreprocessor`, `declUniform`, `declAttribute`, `declVarying`, `declOutput`, `declTopLevel`, `declGlobal`, `emitStmt`, `emitMember`.
- Ordered accumulation is handled with `MutList` inside a region and frozen to a `Vector` at the end. `ShaderSource` has 8 fields: `preprocessor`, `uniforms`, `attributes`, `varyings`, `outputs`, `topLevels`, `globals`, `body`.
- There is no global state and no `Ref[List]`; the handler returns a frozen `ShaderSource` record.
- `Build` carries AST payloads from `Glsl.Ast`, not rendered GLSL fragments. Rendering happens later in `Glsl.Ast.render*` and `Glsl.Render`.

## Nested handlers

- `captureBody` intercepts `emitStmt` while forwarding all declarations and member emissions to the parent handler.
- `captureMembers` intercepts `emitMember` while forwarding statements and declarations to the parent handler.
- This keeps function/control-flow bodies (`Vector[Stmt]`) separate from struct/interface/block members (`Vector[BlockMember]`) instead of mixing them through strings.

## Expression and rendering notes

- Nested string interpolation is fine for this codebase; the printer can stay simple.
- Swizzle read helpers in `src/Glsl/Swizzle.flix` are the preferred ergonomic layer for common accessors.
- Operator rendering should stay parenthesized unless there is a proven need for a precedence-aware printer.
- `Expr[t]` is a phantom wrapper around `Expr.Ast`; heterogeneous children are stored as untyped `Ast` nodes inside `App`, `BinOp`, `Field`, and `Index`. This keeps expression structure available for future optimization passes.

## Caveats

- Function names must be unique per shape, so use different helper names when GLSL signatures overlap.
- There is no unsigned scalar primitive, so `uvec*` constructors take `Int32` expressions and `litU` renders the GLSL suffix.
- Marker traits are useful when a closed phantom family needs shared behavior without trait duplication.
- Phantom enums can use a leading-underscore type parameter when the parameter is intentionally unused.
- Type inference often needs help at declaration sites; ascribe `Expr[t]` explicitly when the target type is not otherwise visible.
- `Proxy[t]` is sometimes necessary to pick a phantom type when there is no value-level evidence.

## Surprises and gotchas

1. `src/Glsl.flix` must exist for `src/Glsl/Types.flix` and friends to be visible.
2. `mod`, `as`, and `discard` are reserved, so use helper names like `modF` and `discardFrag`.
3. Empty enum bodies are illegal, so keep a `Tag` constructor for phantom wrappers.
4. In a module, the companion declaration has to come first.
5. `captureBody` composes cleanly with a parent handler and keeps declaration emission centralized.
6. `uniform` call sites usually need explicit ascription or a `Proxy[t]` parameter.
7. `anyBVec`, `allBVec`, and `notBVec` work well with a single empty trait plus three instances.
8. `uvec*` rendering should prefer `litU(1)` style helpers over raw string concatenation.

## Completion notes

- `uniformWithLayoutAndPrecision` is a clean pattern for combining optional `binding` and `precision` qualifiers.
- `declareUniformBlockMember` now emits a `TopLevel.UBlock`; multi-member blocks use `captureMembers` and the same `TopLevel` path.
- `TopLevel` cases cover structs, interface blocks, uniform blocks, SSBOs, push constants, and functions. Prefer adding a new AST case over introducing a parallel string channel.
- Keep the `#version 300 es` preamble and stage separation as-is.

## Parser absence as design choice

Currently, the DSL has **no GLSL text parser**. All shaders are constructed via the Flix API (smart constructors, expressions). This is intentional:
- **Rationale:** Text parsing requires a separate Glsl/Parse.flix module, but the target AST now exists: produce `ShaderSource` with `Expr.Ast`, `TopLevel`, and `Stmt` nodes.
- **Trade-off:** Cannot load .glsl files directly; must author in Flix. But gains type safety (invalid ops caught at compile time) and full control over AST.
- **Future:** IMPLEMENTING_PARSER.md outlines how to add parsing if needed. Parser should live in Glsl/Parse.flix and emit `ShaderSource` directly.

## Extending variant parameters

`Variants.flix` currently supports boolean flags via `Param.Flag(name, Bool)`. To extend to enums or integers:
1. Add `Param.Enum(String, Set[String])` or `Param.Int(String, List[Int32])` cases.
2. Update `enumerate()` to cartesian-product over all parameter combinations.
3. Add `enumValue(name, combo): String` or `intValue(name, combo): Int32` helpers.
4. Use in shader code: `if (enumValue("mode", combo) == "phong") { ... }`

Current boolean-only design is sufficient for MVP but simple to generalize.

## Module organization and dependencies

The codebase follows a clean dependency hierarchy:

```
Types.flix (foundation)
   ↑
   ├─→ Expr.flix (expression AST)
   ├─→ Ast.flix (declarations/statements; also references Expr)
   └─→ Builtin.flix, Swizzle.flix, Numeric.flix

Build.flix (typed effect over Ast payloads)
   ↑
   └─→ Smart.flix, Render.flix, Variants.flix
```

When adding new modules:
- **Bottom layer:** Types and Expr define primitive type/expression forms.
- **Middle layer:** Ast, Builtin, Swizzle, Numeric, and Build extend those primitives.
- **Top layer:** Smart, Render, Variants. These are user-facing or output.

Avoid circular deps. If a new feature needs both Build and Expr, it belongs in Smart or a new user-facing module.

## Typed AST payloads in the Build effect

The codebase now stores declarations, statements, and block members as typed AST payloads in `Build`. This is:
- **Inspectable:** Tests and future passes can match on `Stmt`, `TopLevel`, and `Uniform`.
- **Parser-ready:** A parser can construct `ShaderSource` without going through smart constructors.
- **Centralized:** String interpolation is concentrated in render helpers rather than spread through `Smart.flix`.

If string building becomes slow (unlikely unless generating 1000s of shaders/sec), optimize `Glsl.Render` or the `Ast.render*` helpers rather than reintroducing early rendering.

## Type inference and ascription

Type inference often needs help at declaration sites. When declaring a uniform or local variable, ascribe the full `Expr[t]` type:

```flix
let mvp: Expr[Mat4] = uniform("mvp")           // Correct
let mvp = uniform("mvp")                       // Risky; may infer Expr[Unknown]
let result = localVar("rgb", Builtin.vec3(...))  // Ascribe if type unclear
```

Use `Proxy[t]` pattern when no value of type t is available:
```flix
let ty = GlslType.typeRef((Proxy.Proxy: Proxy[Mat4]))
```

## Future improvements and roadmap

**Short term:**
- Add enum/integer parameters to Variants.flix.
- Optimize renderStage string building if profiling shows bottleneck.

**Medium term:**
- GLSL text parser (Glsl/Parse.flix) as outlined in IMPLEMENTING_PARSER.md.
- AST optimization passes (constant folding, dead-code elimination, inlining).
- Shader module system (reusable blocks, composition, imports).

**Long term:**
- Multi-stage pipelines (compute shaders, tessellation).
- SPIR-V target for Vulkan.
- Integration bindings (Three.js, Babylon.js, game engines).

## Type-safety guarantees

This DSL provides strong **compile-time** type safety:
- Phantom types prevent mixing Vec2 + Float32, Vec3 * Vec2, etc.
- Invalid array indexing caught (must use Expr[GlslArray[t]]).
- Stage-specific operations enforced (attributes only in vertex, outputs only in fragment).

**Not guaranteed:**
- GLSL runtime semantics (division by zero, out-of-bounds texturing behavior).
- Variable initialization (locals must be explicitly assigned; dead assignments not optimized).
- Performance (generated GLSL may have redundant parentheses, unused locals).

## Flix keyword compatibility (Commit 1 verification)

Tested in Flix 0.72.0: All of the following keywords are **accepted** as enum case names without syntax errors:
- `case If`
- `case For`
- `case Return`
- `case Else`
- `case While`
- `case Break`
- `case Continue`

**Decision:** Use these keywords directly **without suffixes** in `Ast.flix`. No need for `IfS`, `ForS`, `ReturnS`, etc.

This test was performed on 2026-05-13 using a mini enum verification file.

## Build / run

- `cd flix`
- `flix check`
- `flix run`
