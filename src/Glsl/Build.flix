///
/// `Glsl.Build` — the algebraic effect for declaration and statement
/// accumulation.
///
/// Build channels carry typed AST nodes. Rendering is performed later by
/// `Glsl.Render`, using the render helpers in `Glsl.Ast`.
///
pub mod Glsl.Build {

    ///
    /// The typed build effect. Each channel accepts strongly-typed AST nodes.
    ///
    pub eff Build {
        def declPreprocessor(p: Glsl.Ast.Preprocessor): Unit
        def declUniform(u: Glsl.Ast.Uniform): Unit
        def declAttribute(a: Glsl.Ast.Attribute): Unit
        def declVarying(v: Glsl.Ast.Varying): Unit
        def declOutput(o: Glsl.Ast.Output): Unit
        def declTopLevel(d: Glsl.Ast.TopLevel): Unit
        def declGlobal(g: Glsl.Ast.Global): Unit
        def emitStmt(s: Glsl.Ast.Stmt): Unit
        def emitMember(m: Glsl.Ast.BlockMember): Unit
    }

    ///
    /// The frozen output of the new typed `runBuild` invocation.
    /// Each field holds AST nodes for that section.
    ///
    pub type alias ShaderSource = {
        preprocessor = Vector[Glsl.Ast.Preprocessor],
        uniforms     = Vector[Glsl.Ast.Uniform],
        attributes   = Vector[Glsl.Ast.Attribute],
        varyings     = Vector[Glsl.Ast.Varying],
        outputs      = Vector[Glsl.Ast.Output],
        topLevels    = Vector[Glsl.Ast.TopLevel],
        globals      = Vector[Glsl.Ast.Global],
        body         = Vector[Glsl.Ast.Stmt]
    }

    ///
    /// Runs `thunk` under a fresh `Build` handler (typed) and returns the
    /// accumulated declarations and body.
    ///
    pub def runBuild(thunk: Unit -> Unit \ Build): ShaderSource = region rc {
        let pre = MutList.empty(rc);
        let uni = MutList.empty(rc);
        let att = MutList.empty(rc);
        let vry = MutList.empty(rc);
        let out = MutList.empty(rc);
        let top = MutList.empty(rc);
        let gbl = MutList.empty(rc);
        let bod = MutList.empty(rc);
        run {
            thunk()
        } with handler Build {
            def declPreprocessor(p, k) = { MutList.push(p, pre); k() }
            def declUniform(u, k) = { MutList.push(u, uni); k() }
            def declAttribute(a, k) = { MutList.push(a, att); k() }
            def declVarying(v, k) = { MutList.push(v, vry); k() }
            def declOutput(o, k) = { MutList.push(o, out); k() }
            def declTopLevel(d, k) = { MutList.push(d, top); k() }
            def declGlobal(g, k) = { MutList.push(g, gbl); k() }
            def emitStmt(s, k) = { MutList.push(s, bod); k() }
            def emitMember(_m, k) = { k() }
        };
        {
            preprocessor = MutList.toVector(pre),
            uniforms     = MutList.toVector(uni),
            attributes   = MutList.toVector(att),
            varyings     = MutList.toVector(vry),
            outputs      = MutList.toVector(out),
            topLevels    = MutList.toVector(top),
            globals      = MutList.toVector(gbl),
            body         = MutList.toVector(bod)
        }
    }

    ///
    /// Internal helper (typed): runs `thunk` and captures all `emitStmt` calls
    /// into a `Vector[Stmt]`, while forwarding all other `Build` operations
    /// to the parent handler.
    ///
    pub def captureBody(thunk: Unit -> Unit \ Build): Vector[Glsl.Ast.Stmt] \ Build = region rc {
        let bod = MutList.empty(rc);
        run {
            thunk()
        } with handler Build {
            def declPreprocessor(p, k) = { Build.declPreprocessor(p); k() }
            def declUniform(u, k) = { Build.declUniform(u); k() }
            def declAttribute(a, k) = { Build.declAttribute(a); k() }
            def declVarying(v, k) = { Build.declVarying(v); k() }
            def declOutput(o, k) = { Build.declOutput(o); k() }
            def declTopLevel(d, k) = { Build.declTopLevel(d); k() }
            def declGlobal(g, k) = { Build.declGlobal(g); k() }
            def emitStmt(s, k) = { MutList.push(s, bod); k() }
            def emitMember(m, k) = { Build.emitMember(m); k() }
        };
        MutList.toVector(bod)
    }

    ///
    /// Internal helper (typed): runs `thunk` and captures all `emitMember` calls
    /// into a `Vector[BlockMember]`, while forwarding all other `Build` operations
    /// to the parent handler.
    ///
    pub def captureMembers(thunk: Unit -> Unit \ Build): Vector[Glsl.Ast.BlockMember] \ Build = region rc {
        let mem = MutList.empty(rc);
        run {
            thunk()
        } with handler Build {
            def declPreprocessor(p, k) = { Build.declPreprocessor(p); k() }
            def declUniform(u, k) = { Build.declUniform(u); k() }
            def declAttribute(a, k) = { Build.declAttribute(a); k() }
            def declVarying(v, k) = { Build.declVarying(v); k() }
            def declOutput(o, k) = { Build.declOutput(o); k() }
            def declTopLevel(d, k) = { Build.declTopLevel(d); k() }
            def declGlobal(g, k) = { Build.declGlobal(g); k() }
            def emitStmt(s, k) = { Build.emitStmt(s); k() }
            def emitMember(m, k) = { MutList.push(m, mem); k() }
        };
        MutList.toVector(mem)
    }
}
