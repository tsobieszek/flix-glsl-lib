# Comprehensive Codebase Analysis: flix-glsl-lib

## 1. Project Overview

**Project Type:** Domain-Specific Language (DSL) Library / Compiler Frontend

**Description:** A type-safe GLSL ES 300 and GLSL 420 shader DSL implementation written in Flix. This project provides a strongly-typed, compile-time-safe interface for authoring GPU shaders while eliminating entire classes of runtime errors through phantom types and Flix's effect system. Features include phantom-typed expressions, effect-driven declaration accumulation, control flow helpers, user-defined functions, struct and interface block declarations, uniform blocks, Vulkan descriptor sets (set/binding layout), storage buffers, push constants, and preprocessor macro helpers.

**Tech Stack:**
- **Language:** Flix 0.72.0
- **Runtime:** JVM (Java 21)
- **Type System:** Phantom-typed expressions with trait-based type mapping
- **Effect System:** Algebraic effects for declaration accumulation
- **Build Tool:** Flix package manager (flix.toml)

**Architecture Pattern:**
- **Structured AST:** Typed expression trees (`Expr[t]`) plus declaration, statement, and block AST nodes in `Glsl.Ast`
- **Effect-driven accumulation:** Algebraic effects replace global state and accumulate typed AST payloads
- **Centralized rendering:** Smart constructors build AST nodes; `Glsl.Ast` and `Glsl.Render` perform GLSL string generation
- **Parser-ready representation:** A future parser can construct `ShaderSource` directly without going through `Build`

**Language(s) & Versions:**
- Flix 0.72.0 (required, specified in flix.toml)
- Java 21 (runtime dependency for JVM execution)
- GLSL ES 300 and GLSL 4.20 core targets

---

## 2. Detailed Directory Structure Analysis

### Root Directory Structure
```
./
├── flix.toml                     # Package metadata and Flix version lock
├── CLAUDE.md                     # Project architecture guidance
├── FLIX-SKILL.md                 # Flix 0.72.0 syntax reference for LLMs
├── ADDITIONAL_INSIGHTS.md        # Design rationale and implementation notes
├── IMPLEMENTING_PARSER.md        # Guidance for future parser implementation
├── LICENSE.md                    # Project license
├── README.md                     # Project description and API overview
├── src/                          # Source code (Flix modules)
├── test/                         # Test suite (Flix tests)
├── build/                        # Compiled JVM artifacts (generated)
├── lib/                          # Dependencies and caches (generated)
└── .github/workflows/            # CI/CD pipeline definitions
```

### `/src` Directory

**Purpose:** All Flix source modules organized hierarchically by module namespace.

**Key Files:**
- `Glsl.flix` — Root namespace module (required for child modules to be visible)

**Note:** There is no `Main.flix` or `Examples.flix` at the top level; all logic lives under `src/Glsl/`.

**Child Module Structure (`src/Glsl/`):**
1. **Types.flix** — Phantom type tags for GLSL types, `TypeRef`, `Precision`, the `GlslType` trait, derived `typeName`, and convenience proxy constants (`intTy()`, `floatTy()`, `vec3Ty()`, etc.)
2. **Expr.flix** — Phantom-typed `Expr[t]` wrapper around a unified expression `Ast` with render helpers
3. **Ast.flix** — AST for preprocessor directives, layouts, uniforms, attributes, varyings, outputs, globals, top-level declarations, block members, function parameters, loop initializers, statements, and render helpers
4. **Build.flix** — Typed algebraic effect definition (9 operations), `ShaderSource`, `runBuild`, `captureBody`, and `captureMembers`
5. **Stage.flix** — Simple Stage enum (Vertex | Fragment) for stage-conditional rendering
6. **Smart.flix** — User-facing helpers: uniforms, attributes, varyings, outputs, local/const/global variables, structs, interface blocks, uniform blocks, Vulkan descriptors, storage buffers, push constants, control flow, user-defined functions, preprocessor macros, comments
7. **Swizzle.flix** — Typed swizzle helpers (xyz, rgb, xy, etc.) with marker traits for component-access ergonomics
8. **Builtin.flix** — GLSL builtins and constructors (vec2–vec4, mat2–4; math functions; texture sampling and query; type casting)
9. **Numeric.flix** — Traits for same-type arithmetic (Add, Sub, Mul, Div) to enable operator overloading on typed expressions
10. **Render.flix** — `ShaderSource` → GLSL string; stage-conditional (vertex omits outputs/precision, fragment omits attributes); two targets (ES 300 and 4.20 core)
11. **Variants.flix** — Parameter enumeration for shader variants (boolean flags) via Param enum and enumerate function

### `/test` Directory

**Purpose:** Flix `@Test`-annotated test suite (22 files, 97 tests).

| File | Coverage |
|------|----------|
| TestTypes.flix | Phantom type system validation |
| TestAst.flix | AST renderer coverage and direct `ShaderSource` construction |
| TestSwizzle.flix | Swizzle helper rendering |
| TestControl.flix | if/while/for control flow |
| TestControlFlow.flix | Additional control flow |
| TestMatrix.flix | Matrix operations |
| TestTexture.flix | Texture sampling |
| TestTextureLod.flix | Texture LOD functions |
| TestBuiltins.flix | Built-in function output |
| TestCasting.flix | Type casting operations |
| TestAdvancedQualifiers.flix | binding/layout/precision qualifiers |
| TestAdvancedQualifiersGLSL.flix | GLSL output verification for qualifiers |
| TestAdvancedQualifiersExample.flix | Advanced qualifier examples |
| TestDirectives.flix | GLSL 4.20 core rendering |
| TestComments.flix | Comment emission |
| TestConst.flix | Const variable declarations |
| TestStructs.flix | Struct and interface block declarations |
| TestUniformBlocks.flix | Uniform block declarations |
| TestVulkan.flix | Vulkan descriptor sets (set/binding) |
| TestVariants.flix | Shader variant enumeration |
| TestIntegration.flix | End-to-end integration tests |
| TestMain.flix | Minimal smoke test |

### `/.github/workflows` Directory

**Purpose:** GitHub Actions CI/CD pipeline.

**File:** `build-and-test.yaml`
- Runs on pull requests and pushes to main/master
- JDK 21 environment
- Reads Flix version from flix.toml
- Downloads matching Flix release JAR
- Executes `java -jar flix.jar check` (type checking)
- Executes `java -jar flix.jar test` (test suite)

---

## 3. File-by-File Breakdown

### Core Application Files

#### `src/Glsl.flix`
- **Purpose:** Root namespace module for the GLSL DSL
- **Content:** Single `pub mod Glsl {}` declaration (required for visibility of `src/Glsl/*.flix`)
- **Role:** Namespace anchor; no implementations

#### `src/Glsl/Types.flix`
- **Purpose:** Phantom type tags, structured type references, precision qualifiers, and `GlslType` trait for type mapping
- **`TypeRef`:** Primary AST representation of GLSL types (`Float`, `Int`, `Vec*`, `Mat*`, `Sampler*`, `Named`, `Array`)
- **`Precision`:** Closed qualifier enum (`Highp`, `Mediump`, `Lowp`)
- **Rendering:** `renderTypeRef` and `renderPrecision`; `typeName` is derived from `typeRef`
- **Phantom Enums:** Vec2, Vec3, Vec4, IVec2–4, UVec2–4, BVec2–4, Mat2–4, Sampler2D, SamplerCube, Sampler2DArray, Sampler3D, UInt32, GlslStruct[_t], GlslArray[_t]
  - Each carries only a `Tag` constructor (no runtime payload)
  - `with Eq` constraint enables AST comparison
- **GlslType Trait:** Maps type token to `TypeRef` via `typeRef(Proxy[t]): TypeRef`
- **Instances:** 20+ instances mapping Flix types (Float32, Int32, Bool) and phantom types to structured type refs
- **Proxy Convenience Constants:** `intTy()`, `floatTy()`, `boolTy()`, `vec2Ty()`...`mat4Ty()`, `sampler2DTy()`, etc. — save writing `(Proxy.Proxy: Proxy[X])` at call sites
- **Design Rationale:** `Proxy[t]` parameter routes trait dispatch when no value of type t is available at call site

#### `src/Glsl/Expr.flix`
- **Purpose:** Typed expression AST and render function
- **`Expr[t]` Enum:** Phantom wrapper `Of(Ast)`; `t` is compile-time-only type information
- **`Ast` Enum:** 7 cases
  - `Lit(String)` — literal GLSL fragment (e.g., "1.0", "true")
  - `Var(String)` — identifier reference
  - `BinOp(String, Ast, Ast)` — operator with operands
  - `UnOp(String, Ast)` — unary operator
  - `App(String, Vector[Ast])` — function call
  - `Field(Ast, String)` — field/swizzle access (e.g., e.xy)
  - `Index(Ast, Ast)` — array indexing
- **`render()`:** Fold over `Ast` → String with full parenthesization of binary/unary ops
- **`erase()` / `renderExpr()` / `boxed()` / `unbox()`:** Helpers for moving between typed expressions, untyped child ASTs, and rendered fragments

#### `src/Glsl/Ast.flix`
- **Purpose:** AST for declarations, statements, blocks, and render helpers outside expressions
- **Layout and qualifiers:** `LayoutItem`, `Layout`, `VaryingDirection`, `ParamQualifier`
- **Declarations:** `Preprocessor`, `Uniform`, `Attribute`, `Varying`, `Output`, `Global`, `TopLevel`
- **Blocks/functions:** `BlockMember`, `FunctionParam`, `ForInit`
- **Statements:** `Stmt` covers assignments, locals, consts, arrays, if/else-if/else, for, while, break, continue, return, discard, and comments
- **Renderers:** `renderPreprocessor`, `renderUniform`, `renderAttribute`, `renderVarying`, `renderOutput`, `renderGlobal`, `renderTopLevel`, `renderStmt`, `renderBlockMember`, `renderLayout`, `renderForInit`, `renderFunctionParam`
- **Design Rationale:** Keeps smart constructors AST-first and makes parser/optimization work possible without reverse-engineering strings

#### `src/Glsl/Build.flix`
- **Purpose:** Typed effect definition and handler for shader AST accumulation
- **`eff Build`:** 9 operations:
  - `declPreprocessor(p)` — preprocessor directive
  - `declUniform(u)`, `declAttribute(a)`, `declVarying(v)`, `declOutput(o)` — declarations
  - `declTopLevel(d)` — structs, interface blocks, uniform blocks, SSBOs, push constants, functions
  - `declGlobal(g)` — global variable before `main()`
  - `emitStmt(s)` — body statement
  - `emitMember(m)` — struct/block member
- **`ShaderSource`:** Record with 8 typed vector fields: `preprocessor`, `uniforms`, `attributes`, `varyings`, `outputs`, `topLevels`, `globals`, `body`
- **`runBuild()`:** Entry point handler
  - Allocates 8 `MutList`s in a region (one per `ShaderSource` field)
  - Runs thunk under Build handler
  - Each of the 8 declaration/statement operations pushes to its corresponding MutList; `emitMember` is silently discarded (members are only meaningful inside `captureMembers` blocks)
  - Returns frozen `ShaderSource` (lists → vectors)
  - No global state; region-scoped allocation
- **`captureBody()`:** Nested handler
  - Intercepts `emitStmt` calls into a local `MutList`
  - Forwards all other operations to parent handler
  - Returns captured statements as `Vector[Stmt]`
  - Used for function, conditional, and loop bodies
- **`captureMembers()`:** Nested handler
  - Intercepts `emitMember` calls into a local `MutList`
  - Forwards all other operations to parent handler
  - Returns captured members as `Vector[BlockMember]`
  - Used for structs, interface blocks, uniform blocks, SSBOs, and push constants

#### `src/Glsl/Stage.flix`
- **Purpose:** Shader stage discriminant
- **Stage Enum:** `Vertex | Fragment`
- **Derives:** `Eq, ToString`
- **Role:** Used in `Render.renderStage(stage, src)` for stage-conditional rendering

#### `src/Glsl/Smart.flix`
- **Purpose:** User-facing smart constructors and statement helpers (621 lines)
- **Preprocessor Macros:**
  - `define(name, value)`, `defineFn(name, params, body)` — `#define` directives
  - `ifndef(macro, value)` — guarded `#ifndef/#define/#endif` block
  - `extension(name, behavior)`, `include(path)` — `#extension` / `#include`
- **Declaration Helpers:**
  - `uniform(name)`, `uniformWithBinding(name, binding)`, `uniformWithPrecision(name, prec)`, `uniformWithLayoutAndPrecision(name, binding?, prec?)` — uniform variants
  - `uniformWithSet(name, set, binding)`, `samplerWithLayout(name, set, binding)` — Vulkan descriptor sets
  - `attribute(location, name)`, `varying(direction, name)`, `output(location, name)`
  - `localVar(name, rhs)`, `floatVar/vec2Var/vec3Var/vec4Var/intVar(name)` — local variables
  - `constVar(name, rhs)` — `const T name = rhs;`
  - `globalVar(name, rhs)` — global variable placed before `main()`
  - `uniformArray(name, size)`, `localArray(name, size)` — fixed-size arrays
- **Struct/Block Declarations:**
  - `declareStruct(name, builder)`, `structMember(name)`, `structMemberTyped(name, proxy)` — GLSL structs
  - `declareInterfaceBlock(dir, name, instance, builder)` — in/out interface blocks
  - `declareUniformBlock(blockName, builder, binding)` — single-instance uniform interface block
  - `declareUniformBlockMember(blockName, memberName, binding)` — single-member shorthand
  - `declareUniformBlockMulti(blockName, instance, set?, binding, builder)` — multi-member uniform block with optional `set`
  - `uniformBlockMember(name)`, `uniformBlockMemberTyped(name, proxy)` — members inside a block
  - `storageBuffer(bufName, instance, set, binding, builder)` — Vulkan SSBO
  - `pushConstant(blockName, instance, builder)` — Vulkan push constants
- **Built-in Variables:**
  - `glPosition()`, `glFragCoord()`, `glFrontFacing()`, `glViewIndex()` — no emission, pure `Expr.Var` references
- **Control Flow:**
  - `ifStmt(cond, body)`, `elseIfStmt(cond, body)`, `elseStmt(body)` — conditionals
  - `forLoop(init, cond, incr, body)`, `whileLoop(cond, body)` — loops
  - `breakStmt()`, `continueStmt()`, `returnStmt()`, `returnExpr(e)` — jump statements
  - `discardFrag()` — `discard;` (`discard` is a Flix reserved word)
- **User-Defined Functions:**
  - `defineFunction(name, retType, params, body)` — captures body via `captureBody`, emits `TopLevel.Function` through `declTopLevel`
  - `param(name, proxy)`, `inoutParam(name, proxy)`, `constParam(name, proxy)` — parameter string helpers
- **Assignment/Access:**
  - `assign(lhs, rhs)`, `assignField(parent, field, rhs)` — assignment statements
  - `blockAccess(block, member)` — dot-access on a block instance
- **Comments:**
  - `comment(text)` — `// text`; `blockComment(text)` — `/* text */`
  - `commentMember(text)`, `blockCommentMember(text)` — member comments inside structs/blocks
- **Design Rationale:** Declaration as side effect of smart constructor call provides ergonomic API

#### `src/Glsl/Swizzle.flix`
- **Purpose:** Typed swizzle helpers for common component accessors
- **Examples:**
  - `xyz(e: Expr[Vec4]): Expr[Vec3]`, `rgb(e: Expr[Vec4]): Expr[Vec3]`
  - `xy`, `rg`, `st`, and aliases for Vec4/Vec3/Vec2 targets

#### `src/Glsl/Builtin.flix`
- **Purpose:** GLSL builtins and constructors (725 lines)
- **Constructors:** vec2–vec4, ivec2–4, uvec2–4, bvec2–4, mat2–4
- **Math Functions:** abs, sin, cos, tan, asin, acos, atan, sqrt, exp, log, floor, ceil, fract, sign, length, normalize, dot, cross, pow, atan2, min, max, mix, clamp, step, smoothstep, distance; matrix ops: mulMatVec, transpose, inverse, outerProduct; modF for GLSL `mod`
- **Texture Sampling:** texture, textureLod, textureSize, textureOffset, textureLodOffset, textureGrad
- **Type Casting:** intToFloat, floatToInt, etc.
- **Literals:** litF, litI, litU, litB

#### `src/Glsl/Numeric.flix`
- **Purpose:** Traits for same-type arithmetic on phantom-typed expressions
- **Traits:** `Add[t]`, `Sub[t]`, `Mul[t]`, `Div[t]`
- **Instances:** Vec2–Vec4, IVec2–4, Mat2–4, Float32

#### `src/Glsl/Render.flix`
- **Purpose:** `ShaderSource` → GLSL string with stage-conditional layout
- **`renderStage(stage, src): String`** — GLSL ES 300 (`#version 300 es`)
  - Section order: preamble, preprocessor directives, precision (fragment only), uniforms, attributes (vertex only), varyings, outputs (fragment only), top-level declarations, globals, `void main() {`, body, `}`
  - Empty sections filtered out (`List.filter(s -> not String.isEmpty(s), ...)`)
- **`renderStage420(stage, src): String`** — GLSL 4.20 core (`#version 420 core`)
  - Same section order; no precision qualifier
- **Body Rendering:** Uses `Vector.flatMap(Ast.renderStmt)` so multi-line statements are indented line-by-line
- **Design Rationale:** Stage conditioning eliminates dead code in output; two targets support both mobile and desktop GLSL

#### `src/Glsl/Variants.flix`
- **Purpose:** Parameter enumeration for shader variants
- **`Param` Enum:** `Flag(String, Bool)` — parameterized boolean control
- **`ParamSpec` Enum:** `FlagSpec(String)` — specification of variant parameter
- **`ParamCombo`:** `Vector[Param]` — one combination of parameters
- **`enumerate(specs, runner)`:** Enumerates all combinations (2^n for n flags)
- **`flag(name, combo): Bool`** — looks up flag value in combo

### Configuration Files

#### `flix.toml`
- name = "flix-glsl-lib", version = "0.1.1"
- flix = "0.72.0" (version constraint)
- repository = "github:tsobieszek/flix-glsl-lib"
- authors = ["Tomasz Sobieszek <tom.sobieszek@gmail.com>"]

#### Documentation files
- **`CLAUDE.md`** — Architecture guide for LLM code generation (build commands, design notes, module layout, gotchas)
- **`FLIX-SKILL.md`** — Flix 0.72.0 syntax reference (breaking changes from older versions)
- **`ADDITIONAL_INSIGHTS.md`** — Implementation rationale and gotchas
- **`IMPLEMENTING_PARSER.md`** — Blueprint for future GLSL text parser
- **`README.md`** — Comprehensive user-facing documentation with quick-start examples and API reference

---

## 4. API Endpoints Analysis

**Not Applicable:** This is a DSL library, not an HTTP API. However, the public API surface is:

### Top-Level Entry Points

1. **`Glsl.Build.runBuild(thunk: Unit -> Unit \ Build): ShaderSource`**
2. **`Glsl.Render.renderStage(stage: Stage, src: ShaderSource): String`** — GLSL ES 300
3. **`Glsl.Render.renderStage420(stage: Stage, src: ShaderSource): String`** — GLSL 4.20 core

### Declaration API (Smart Constructors)

```flix
// Uniforms
uniform(name): Expr[t] \ Build
uniformWithBinding(name, binding): Expr[t] \ Build
uniformWithPrecision(name, prec): Expr[t] \ Build
uniformWithLayoutAndPrecision(name, binding?, prec?): Expr[t] \ Build
uniformWithSet(name, set, binding): Expr[t] \ Build

// Attributes / Varyings / Outputs
attribute(location, name): Expr[t] \ Build
varying(direction, name): Expr[t] \ Build
output(location, name): Expr[t] \ Build

// Variables
localVar(name, rhs): Expr[t] \ Build
constVar(name, rhs): Expr[t] \ Build
globalVar(name, rhs): Expr[t] \ Build

// Statements
assign(lhs, rhs): Unit \ Build
assignField(lhs, field, rhs): Unit \ Build
discardFrag(): Unit \ Build

// Structs / Blocks
declareStruct(name, builder): Unit \ Build
declareInterfaceBlock(dir, name, instance, builder): Unit \ Build
declareUniformBlockMulti(blockName, instance, set?, binding, builder): Unit \ Build
storageBuffer(name, instance, set, binding, builder): Unit \ Build
pushConstant(blockName, instance, builder): Unit \ Build

// Functions
defineFunction(name, retType, params, body): Unit \ Build
returnExpr(e): Unit \ Build

// Control Flow
ifStmt(cond, body): Unit \ Build
forLoop(init, cond, incr, body): Unit \ Build
whileLoop(cond, body): Unit \ Build

// Preprocessor
define(name, value): Unit \ Build
defineFn(name, params, body): Unit \ Build
ifndef(macro, value): Unit \ Build
```

### Expression API (Builtins)

```flix
vec2, vec3, vec4, ivec*, uvec*, bvec*, mat*    // constructors
sin, cos, abs, sqrt, normalize, dot, cross      // math
transpose, inverse, outerProduct                // matrix
texture, textureLod, textureSize                // texture
litF, litI, litU, litB                          // literals
```

### Variant API

```flix
Glsl.Variants.enumerate(specs, runner): Vector[(ParamCombo, {vertex: String, fragment: String})]
Glsl.Variants.flag(name, combo): Bool
```

---

## 5. Architecture Deep Dive

### Overall Application Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        User Application                          │
└────────────────────────┬─────────────────────────────────────────┘
                         │
        ┌────────────────┴────────────────┐
        │                                 │
        ▼                                 ▼
   ┌─────────────────┐         ┌──────────────────┐
   │  Smart API      │         │  Builtins        │
   │                 │         │                  │
   │ uniform()       │         │ vec2/vec3/vec4   │
   │ defineFunction()│         │ sin/cos/abs      │
   │ declareStruct() │         │ texture()        │
   │ ifStmt()        │         │ litF/litI        │
   └────────┬────────┘         └────────┬─────────┘
            │                          │
            └──────────────┬───────────┘
                           │
                    ┌──────▼──────┐
                    │ Expr[t] AST │
                    │ + Expr.Ast  │
                    └──────┬──────┘
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
      ┌──────────────────┐    ┌────────────────┐
      │ Build Effect     │    │ Numeric Traits │
      │ (9 typed ops)    │    │ Add, Sub, Mul  │
      │                  │    │ Div            │
      │ ┌──────────────┐ │    └────────────────┘
      │ │ 8 MutLists   │ │
      │ │  in region   │ │
      │ └──────────────┘ │
      └────────┬─────────┘
               │
        ┌──────▼──────────┐
        │ ShaderSource    │
        │  (AST vectors,  │
        │   frozen)       │
        └────────┬────────┘
                 │
      ┌──────────┴──────────┐
      │                     │
      ▼                     ▼
 ┌──────────────┐  ┌────────────────┐
 │ renderStage  │  │ Variants       │
 │ (ES 300 /   │  │ enumerate()    │
 │  4.20 core)  │  └────────────────┘
 └────────┬─────┘
          ▼
    ┌──────────────┐
    │ GLSL String  │
    └──────────────┘
```

### Data Flow and Request Lifecycle

1. **Initialization:** `Glsl.Build.runBuild(thunk)` — handler allocates 8 MutLists in a region
2. **Declaration Phase:** Smart constructors push typed AST nodes to MutLists via Build effect
3. **Expression Construction:** Builtins/operators build `Expr[t]` wrappers around `Expr.Ast`
4. **Nested Capture:** `captureBody` intercepts `emitStmt` for statement bodies; `captureMembers` intercepts `emitMember` for block members
5. **Accumulation:** `assign()` and other statement helpers push `Stmt` values to the body MutList
6. **Freezing:** Handler exits; MutLists → Vectors; returns `ShaderSource`
7. **Rendering:** `renderStage(stage, src)` walks AST nodes, assembles sections with stage conditioning, and filters empty sections

### Key Design Patterns

1. **Phantom Types** — Tags carry no runtime payload; `Proxy[t]` routes trait dispatch
2. **Algebraic Effects** — `Build` effect replaces global state; region-scoped `MutList` accumulation
3. **Typed Build Payloads** — Channels accept `Preprocessor`, `Uniform`, `TopLevel`, `Stmt`, and related AST nodes
4. **Expression Erasure to `Expr.Ast`** — Heterogeneous expression children are stored as untyped AST nodes while public APIs retain phantom typing
5. **Nested Handlers via `captureBody()` / `captureMembers()`** — Intercept local statements or block members while forwarding declarations
6. **Smart Constructors as Ergonomic API** — Declaration is a side effect of binding: `let mvp = uniform("mvp")`
7. **Stage-Conditional Rendering** — `renderStage` omits irrelevant sections; empty sections filtered
8. **`TopLevel` AST Cases** — Structs, interface blocks, uniform blocks, SSBOs, push constants, and functions share one top-level rendering path

### Module Dependencies

```
Smart.flix
  ├─→ Build.flix (Build effect, captureBody)
  ├─→ Ast.flix (declaration/statement nodes)
  ├─→ Expr.flix (Expr[t], erase, render)
  ├─→ Types.flix (GlslType trait, TypeRef, Proxy[t])
  └─→ Builtin.flix (litF/litI constructors)

Expr.flix        (no dependencies)
Types.flix       (no dependencies)
Ast.flix         (Types, Expr)
Build.flix       (Ast; uses Flix MutList)

Builtin.flix
  ├─→ Expr.flix
  └─→ Types.flix

Swizzle.flix
  ├─→ Expr.flix
  └─→ Types.flix

Numeric.flix
  ├─→ Expr.flix
  └─→ Types.flix

Render.flix
  ├─→ Build.flix (ShaderSource type)
  ├─→ Ast.flix (render helpers)
  └─→ Stage.flix (Stage enum)

Variants.flix
  ├─→ Build.flix (runBuild)
  └─→ Render.flix (renderStage)
```

---

## 6. Environment & Setup Analysis

### Required Environment Variables

**None.** The project is self-contained; all configuration is in `flix.toml`.

### Installation and Setup Process

1. **System Prerequisites:** Java 21, Flix 0.72.0
2. **Clone and Build:**
   ```bash
   git clone github:tsobieszek/flix-glsl-lib
   cd flix
   flix check   # type-check
   flix test    # run tests
   flix run     # generate GLSL output
   ```

### CI/CD Pipeline

**GitHub Actions (`build-and-test.yaml`):**
- Trigger: PR or push to main/master
- Steps: Checkout → JDK 21 (Temurin) → read flix.toml version → download flix.jar → `flix check` → `flix test`

### Production Deployment

- `flix build-jar` compiles to `artifact/flix-glsl-lib.jar`
- Distribute as library; call Flix code from Java host (game engine, graphics tool)
- Generated GLSL strings written to `.vert`/`.frag` files or shipped inline

---

## 7. Technology Stack Breakdown

| Component | Version | Purpose |
|-----------|---------|---------|
| JVM | Java 21 | Code execution |
| Flix | 0.72.0 | Language runtime and compiler |

### Flix Language Features Used

| Feature | Usage |
|---------|-------|
| Phantom Types | Vec2–Vec4, Mat*, GlslStruct[_t], etc. |
| Algebraic Effects | Build effect (9 typed ops) for declaration and statement accumulation |
| Traits | GlslType, Add, Sub, Mul, Div |
| Regions | MutList allocation and scoping in runBuild |
| Pattern Matching | Expr rendering, Stage conditioning |
| String Interpolation | Centralized GLSL rendering helpers |
| Enums | Expr[t], Expr.Ast, Glsl.Ast nodes, Param, ParamSpec, Stage |
| Proxy[t] | Type witness for trait dispatch without value |

**No external dependencies** — Flix standard library only.

---

## 8. Visual Architecture Diagram

### Component Relationship

```
                    ┌─────────────────────┐
                    │   Types.flix        │
                    │ TypeRef, Precision, │
                    │ phantom tags        │
                    └────────┬────────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │
              ▼              ▼
         ┌─────────┐  ┌─────────────┐
         │ Expr    │  │ Ast.flix    │
         │ .flix   │  │ decls/stmts │
         └────┬────┘  └──────┬──────┘
              │              │
              ├──────────────┼───────────────┐
              │              │               │
              ▼              ▼               ▼
        ┌──────────┐  ┌─────────────┐  ┌────────────┐
        │ Builtin  │  │ Build.flix  │  │ Swizzle    │
        │ .flix    │  │ 9 typed ops │  │ .flix      │
        └────┬─────┘  └──────┬──────┘  └─────┬──────┘
              │              │               │
              └──────────────┼───────────────┘
                             │
                      ┌──────▼──────┐
                      │ Smart.flix  │
                      │ (621 lines) │
                      └──────┬──────┘
                             │
        ┌────────────────┴─────────────────┐
        │                                  │
        ▼                                  ▼
   ┌──────────┐                       ┌─────────┐
   │ Render   │                       │Variants │
   │ .flix    │                       │ .flix   │
   └────┬─────┘                       └────┬────┘
        │                                  │
        └────────────────┬─────────────────┘
                        │
                        ▼
                  GLSL strings
```

### Data Flow

```
User: let mvp = uniform("mvp")
           │
           ▼  Smart.uniform()
           │  → GlslType.typeRef(Proxy[Mat4]) = TypeRef.Mat4
           │  → Build.declUniform(Uniform.U(...))
           │  → MutList.push(uniformAst, uni)
           │  → return Expr.Of(Ast.Var("mvp"))
           │
User: assign(glPosition(), mulMatVec(mvp, vec4(pos, litF(1.0f32))))
           │
           ▼  Smart.assign()
           │  → Build.emitStmt(Stmt.Assign(Var("gl_Position"), App("*", ...)))
           │  → MutList.push(stmtAst, bod)
           │
           ▼  runBuild exits
           │  MutLists → Vectors → ShaderSource
           │
           ▼  renderStage(Stage.Vertex, src)
           │  Render AST sections (filter empty)
           │
           ▼  "#version 300 es\nuniform mat4 mvp;\n...\nvoid main() {\n    gl_Position = ...;\n}"
```

### File Hierarchy

```
flix/
├── flix.toml                          # version: 0.1.1, flix: 0.72.0
├── src/
│   ├── Glsl.flix                      # Root namespace anchor
│   └── Glsl/
│       ├── Types.flix                 # TypeRef, Precision, phantom types
│       ├── Expr.flix                  # Expression AST, render
│       ├── Ast.flix                   # Declarations/statements/blocks AST
│       ├── Build.flix                 # Effect (9 typed ops), ShaderSource
│       ├── Stage.flix                 # Vertex/Fragment enum
│       ├── Smart.flix                 # User-facing API (621 lines)
│       ├── Swizzle.flix               # Swizzle helpers
│       ├── Builtin.flix               # GLSL builtins (725 lines)
│       ├── Numeric.flix               # Arithmetic traits
│       ├── Render.flix                # ShaderSource → GLSL string
│       └── Variants.flix              # Parameter enumeration
└── test/                              # 22 test files, 97 @Test functions
```

---

## 9. Key Insights & Recommendations

### Code Quality Assessment

#### Strengths

1. **Type Safety:** Phantom types eliminate entire classes of GLSL errors at compile time.
2. **Effect-Based State:** No global state; all accumulation is region-scoped and deterministic.
3. **Comprehensive API:** Smart.flix covers declarations, control flow, user functions, structs, uniform blocks, Vulkan descriptors, storage buffers, push constants, and preprocessor macros.
4. **Dual-Target Rendering:** `renderStage` (ES 300) and `renderStage420` (GLSL 4.20 core) with shared ShaderSource.
5. **Structured AST:** Declarations, statements, top-level constructs, and expressions remain inspectable after `runBuild`.
6. **Ergonomic Proxy Constants:** `vec3Ty()` etc. eliminate boilerplate at call sites.
7. **Comprehensive Testing:** 22 test files covering AST renderers, types, math, control flow, qualifiers, texture, structs, Vulkan.

#### Weaknesses

1. **No Parser:** All shaders must be constructed via API; `.glsl` files cannot be imported.
2. **Boolean-Only Variants:** Variants.flix only supports boolean flags; integer/enum variants are future work.
3. **Manual Deduplication:** Smart constructors re-emit if called multiple times; caller must avoid.
4. **`src/Main.flix` absent:** No executable entry point in the project at present; shaders are exercised through tests.
5. **Legacy Wrappers:** Some APIs (`forLoop`, `defineFunction` params, string `varying`) preserve compatibility by wrapping strings into AST literals or parsed params.

### Potential Improvements

#### Short Term
1. **Re-add a `Main.flix` entry point** — demonstrates the API and serves as a quick smoke test.
2. **Enum/integer variant parameters** — generalize `Variants.flix` beyond boolean flags.
3. **Deduplication guard** — optional `Set[String]` in `runBuild` to prevent duplicate declarations.

#### Medium Term
1. **Parser Implementation** — GLSL text parsing to AST (`IMPLEMENTING_PARSER.md` blueprint).
2. **Optimization Passes** — constant folding, dead-code elimination, inlining over `Expr.Ast` and `Glsl.Ast`.
3. **Shader Module System** — reusable shader libraries with composition.

#### Long Term
1. **Multi-Stage Pipelines** — compute, tessellation stages.
2. **SPIR-V Target** — compile to SPIR-V bytecode for Vulkan.
3. **Type-Safe Vulkan Descriptor Layout** — phantom-type enforcement of set/binding combinations.

### Security Considerations

1. **No Injection Risk:** All shader code is type-checked at compile time.
2. **Deterministic Rendering:** Pure function; same input → identical GLSL.
3. **No `unsafe` Blocks** in core modules; all operations are safe.

### Performance Notes

1. **String Building:** `String.unlines` / `Vector.join` are adequate for typical shader sizes.
2. **Region Allocation:** `MutList` in region is O(1) amortized push; no concern at shader-generation rates.
3. **Caching Opportunity:** `renderStage` results could be memoized for identical `ShaderSource` inputs.

### Architectural Debt

1. **Compatibility Wrappers** — some public helpers still accept strings and wrap them into AST literals to preserve older call sites.
2. **Single-Pass Rendering** — no optimization pass between AST accumulation and GLSL output yet.

---

## Conclusion

**flix-glsl-lib** (v0.1.1) is a well-architected, type-safe shader DSL that leverages Flix's phantom types and algebraic effects to eliminate GLSL errors at compile time. The API has grown substantially beyond basic declarations to include control flow, user-defined functions, structs, interface blocks, uniform blocks, Vulkan descriptor sets, storage buffers, push constants, and preprocessor macros — all tested across 22 test files. The main limitation is the lack of a text parser; the AST is now in place for one. The project targets both GLSL ES 300 (mobile) and GLSL 4.20 core (desktop) with a shared structured `ShaderSource` representation.

---

*Analysis updated 2026-05-13. Flix version: 0.72.0. Package version: 0.1.1. Total @Test functions: 97 across 22 test files.*
