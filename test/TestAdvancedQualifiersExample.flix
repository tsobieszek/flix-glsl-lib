///
/// Example demonstrating advanced qualifiers (layout binding, precision, interface blocks).
///

pub mod TestAdvancedQualifiersExample {
    use Glsl.Build.runBuild
    use Glsl.Render.renderStage
    use Glsl.Stage.Stage
    use Glsl.Smart.{uniformWithBinding, uniformWithPrecision, uniformWithLayoutAndPrecision, declareUniformBlockMember}
    use Glsl.Builtin.vec4FromVec3
    use Glsl.Builtin.litF
    use Glsl.Types.Mat4
    use Glsl.Types.Vec3
    use Glsl.Types.Vec4

    def vertexBody(): Unit \ Glsl.Build.Build =
        let mvp: Glsl.Expr.Expr[Mat4] = uniformWithBinding("mvp", 0);
        let position: Glsl.Expr.Expr[Vec3] = Glsl.Smart.attribute(0, "position");
        let glPos: Glsl.Expr.Expr[Vec4] = Glsl.Smart.varying("out", "gl_Position");
        Glsl.Smart.assign(glPos, Glsl.Builtin.mulMatVec(mvp, vec4FromVec3(position, litF(1.0f32))))

    def fragmentBody(): Unit \ Glsl.Build.Build =
        let colorUniform: Glsl.Expr.Expr[Vec3] = uniformWithPrecision("color", "mediump");
        let fragOut: Glsl.Expr.Expr[Vec4] = Glsl.Smart.output(0, "fragColor");
        Glsl.Smart.assign(fragOut, vec4FromVec3(colorUniform, litF(1.0f32)))

    pub def vertexSource(): String =
        renderStage(Stage.Vertex, runBuild(_ -> vertexBody()))

    pub def fragmentSource(): String =
        renderStage(Stage.Fragment, runBuild(_ -> fragmentBody()))
}
