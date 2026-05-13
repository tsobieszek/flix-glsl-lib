///
/// Tests for correct GLSL output of advanced qualifiers.
///

mod TestAdvancedQualifiersGLSL {
    use Glsl.Build.runBuild

    @Test
    def testBindingQualifierGLSLOutput(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _u: Glsl.Expr.Expr[Float32] = Glsl.Smart.uniformWithBinding("myUniform", 0);
            ()
        });
        let glslVertex = Glsl.Render.renderStage(Glsl.Stage.Vertex, src);
        let hasBinding = String.contains({substr = "layout(binding = 0) uniform float myUniform;"}, glslVertex);
        Assert.assertTrue(hasBinding)
    }

    @Test
    def testPrecisionQualifierGLSLOutput(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _u: Glsl.Expr.Expr[Float32] = Glsl.Smart.uniformWithPrecision("color", "mediump");
            ()
        });
        let glslVertex = Glsl.Render.renderStage(Glsl.Stage.Vertex, src);
        let hasPrecision = String.contains({substr = "uniform mediump float color;"}, glslVertex);
        Assert.assertTrue(hasPrecision)
    }

    @Test
    def testBindingAndPrecisionGLSLOutput(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _u: Glsl.Expr.Expr[Float32] = Glsl.Smart.uniformWithLayoutAndPrecision("intensity", Some(1), Some("highp"));
            ()
        });
        let glslVertex = Glsl.Render.renderStage(Glsl.Stage.Vertex, src);
        let hasQualifiers = String.contains({substr = "layout(binding = 1) uniform highp float intensity;"}, glslVertex);
        Assert.assertTrue(hasQualifiers)
    }

    @Test
    def testUniformBlockGLSLOutput(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let _u: Glsl.Expr.Expr[Float32] = Glsl.Smart.declareUniformBlockMember("CameraBlock", "viewDistance", 0);
            ()
        });
        let glslVertex = Glsl.Render.renderStage(Glsl.Stage.Vertex, src);
        let hasBlockSig = String.contains({substr = "uniform CameraBlock"}, glslVertex);
        let hasMember = String.contains({substr = "float viewDistance;"}, glslVertex);
        Assert.assertTrue(hasBlockSig and hasMember)
    }

    @Test
    def testFullShaderWithAdvancedQualifiers(): Unit \ Assert = {
        let src = runBuild(_ -> {
            let mvp: Glsl.Expr.Expr[Glsl.Types.Mat4] = Glsl.Smart.uniformWithBinding("mvp", 0);
            let _color: Glsl.Expr.Expr[Glsl.Types.Vec3] = Glsl.Smart.uniformWithPrecision("color", "mediump");
            let position: Glsl.Expr.Expr[Glsl.Types.Vec3] = Glsl.Smart.attribute(0, "position");
            let glPos: Glsl.Expr.Expr[Glsl.Types.Vec4] = Glsl.Smart.varying("out", "gl_Position");
            Glsl.Smart.assign(glPos, Glsl.Builtin.mulMatVec(mvp, Glsl.Builtin.vec4FromVec3(position, Glsl.Builtin.litF(1.0f32))));
            ()
        });
        let glslVertex = Glsl.Render.renderStage(Glsl.Stage.Vertex, src);
        let hasBinding = String.contains({substr = "layout(binding = 0) uniform mat4 mvp;"}, glslVertex);
        let hasPrecision = String.contains({substr = "uniform mediump vec3 color;"}, glslVertex);
        Assert.assertTrue(hasBinding and hasPrecision)
    }
}
