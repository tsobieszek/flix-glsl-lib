///
/// `Glsl.Build` — the algebraic effect for declaration and statement
/// accumulation.
///
/// Each emission goes through one of five typed channels (uniform /
/// attribute / varying / output / body). The handler accumulates the
/// strings into `MutList`s allocated in a region and returns a
/// `ShaderSource` record at the end. Because all payloads are already-
/// rendered `String`s, the effect itself stays monomorphic — sidestepping
/// the open question about polymorphic effects in Flix 0.72.0.
///
/// The accumulator implementation deliberately uses `MutList.push` (O(1)
/// amortized) inside a `region`, then converts to `Vector` on exit. This
/// validates the "Things I am less sure about" worry from
/// `ADDITIONAL_INSIGHTS.md` — no `Ref[List]` required, no global state.
///
pub mod Glsl.Build {

    ///
    /// The build effect. All channels accept already-formatted GLSL
    /// fragments (see `Glsl.Smart` for the helpers that produce them).
    ///
    pub eff Build {
        def declExtension(line: String): Unit
        def declInclude(line: String): Unit
        def declDefine(line: String): Unit
        def declUniform(line: String): Unit
        def declAttribute(line: String): Unit
        def declVarying(line: String): Unit
        def declOutput(line: String): Unit
        def declFunction(sig: String, body: Vector[String]): Unit
        def declBlock(sig: String, body: Vector[String], footer: String): Unit
        def declGlobal(line: String): Unit
        def emitStmt(line: String): Unit
        def declComment(line: String): Unit
    }

    ///
    /// The frozen output of one `runBuild` invocation. Each field is the
    /// list of fully-rendered GLSL lines for that section, in emission
    /// order.
    ///
    pub type alias ShaderSource = {
        extensions = Vector[String],
        defines = Vector[String],
        includes = Vector[String],
        uniforms = Vector[String],
        attributes = Vector[String],
        varyings = Vector[String],
        outputs = Vector[String],
        functions = Vector[String],
        globals = Vector[String],
        body = Vector[String]
    }

    ///
    /// Runs `thunk` under a fresh `Build` handler and returns the
    /// accumulated declarations and body.
    ///
    pub def runBuild(thunk: Unit -> Unit \ Build): ShaderSource = region rc {
        let ext = MutList.empty(rc);
        let dfs = MutList.empty(rc);
        let inc = MutList.empty(rc);
        let uni = MutList.empty(rc);
        let att = MutList.empty(rc);
        let vry = MutList.empty(rc);
        let out = MutList.empty(rc);
        let fun = MutList.empty(rc);
        let gbl = MutList.empty(rc);
        let bod = MutList.empty(rc);
        run {
            thunk()
        } with handler Build {
            def declExtension(line, k) = { MutList.push(line, ext); k() }
            def declDefine(line, k) = { MutList.push(line, dfs); k() }
            def declInclude(line, k) = { MutList.push(line, inc); k() }
            def declUniform(line, k) = { MutList.push(line, uni); k() }
            def declAttribute(line, k) = { MutList.push(line, att); k() }
            def declVarying(line, k) = { MutList.push(line, vry); k() }
            def declOutput(line, k) = { MutList.push(line, out); k() }
            def declFunction(sig, body, k) = {
                MutList.push("${sig} {", fun);
                body |> Vector.forEach(line -> MutList.push("    ${line}", fun));
                MutList.push("}", fun);
                k()
            }
            def declBlock(sig, body, footer, k) = {
                MutList.push("${sig} {", fun);
                body |> Vector.forEach(line -> MutList.push("    ${line}", fun));
                MutList.push("}${footer}", fun);
                k()
            }
            def declGlobal(line, k) = { MutList.push(line, gbl); k() }
            def emitStmt(line, k) = { MutList.push(line, bod); k() }
            def declComment(line, k) = { MutList.push(line, bod); k() }
        };
        {
            extensions = MutList.toVector(ext),
            defines = MutList.toVector(dfs),
            includes = MutList.toVector(inc),
            uniforms = MutList.toVector(uni),
            attributes = MutList.toVector(att),
            varyings = MutList.toVector(vry),
            outputs = MutList.toVector(out),
            functions = MutList.toVector(fun),
            globals = MutList.toVector(gbl),
            body = MutList.toVector(bod)
        }
    }

    ///
    /// Internal helper: runs `thunk` and captures all `emitStmt` calls
    /// into a `Vector[String]`, while forwarding all other `Build`
    /// operations to the parent handler.
    ///
    pub def captureBody(thunk: Unit -> Unit \ Build): Vector[String] \ Build = region rc {
        let bod = MutList.empty(rc);
        run {
            thunk()
        } with handler Build {
            def declExtension(line, k) = { Build.declExtension(line); k() }
            def declInclude(line, k) = { Build.declInclude(line); k() }
            def declDefine(line, k) = { Build.declDefine(line); k() }
            def declUniform(line, k) = { Build.declUniform(line); k() }
            def declAttribute(line, k) = { Build.declAttribute(line); k() }
            def declVarying(line, k) = { Build.declVarying(line); k() }
            def declOutput(line, k) = { Build.declOutput(line); k() }
            def declFunction(sig, body, k) = { Build.declFunction(sig, body); k() }
            def declBlock(sig, body, footer, k) = { Build.declBlock(sig, body, footer); k() }
            def declGlobal(line, k) = { Build.declGlobal(line); k() }
            def emitStmt(line, k) = { MutList.push(line, bod); k() }
            def declComment(line, k) = { MutList.push(line, bod); k() }
        };
        MutList.toVector(bod)
    }
}
