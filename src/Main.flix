def main(): Unit \ IO =
    let src = Glsl.Build.runBuild(_ -> {
        let _mvp: Glsl.Expr.Expr[Glsl.Types.Mat4] = Glsl.Smart.uniformWithBinding("mvp", 0);
        let _color: Glsl.Expr.Expr[Glsl.Types.Vec3] = Glsl.Smart.uniformWithPrecision("color", "mediump");
        let _intensity: Glsl.Expr.Expr[Float32] = Glsl.Smart.uniformWithLayoutAndPrecision("intensity", Some(1), Some("highp"));
        ()
    });
    let glsl = Glsl.Render.renderStage(Glsl.Stage.Vertex, src);
    println(glsl)
