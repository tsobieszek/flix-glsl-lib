///
/// `Glsl.Render` — pretty-prints a `ShaderSource` (the output of one
/// `runBuild` call) into the final GLSL ES 300 or GLSL 4.20 source string for either
/// the vertex or fragment stage.
///
/// Stage-conditional layout omits irrelevant sections:
///
/// GLSL ES 300:
///   #version 300 es
///   precision highp float;          // fragment only, GLSL ES 300 requirement
///   <uniforms>
///   <attributes>                    // vertex only
///   <varyings>
///   <outputs>                       // fragment only
///   void main() {
///       <body>
///   }
///
/// GLSL 4.20 core:
///   #version 420 core
///   #extension GL_ARB_separate_shader_objects : enable
///   #extension GL_ARB_shading_language_420pack : enable
///   #include "..."
///   <uniforms>
///   <attributes>                    // vertex only
///   <varyings>
///   <outputs>                       // fragment only
///   void main() {
///       <body>
///   }
///
pub mod Glsl.Render {

    use Glsl.Ast
    use Glsl.Stage.Stage
    use Glsl.Build
    use Glsl.Build.ShaderSource

    pub def renderStage(stage: Stage, src: ShaderSource): String =
        let {preprocessor = pre, uniforms = uni, attributes = att, varyings = vry, outputs = out, topLevels = top, globals = gbl, body = bod} = src;
        let preamble = "#version 300 es";
        let precision = match stage {
            case Stage.Fragment => "precision highp float;"
            case Stage.Vertex   => ""
        };
        let attributes = match stage {
            case Stage.Vertex   => att |> Vector.map(Ast.renderAttribute) |> Vector.toList |> String.intercalate("\n")
            case Stage.Fragment => ""
        };
        let outputs = match stage {
            case Stage.Fragment => out |> Vector.map(Ast.renderOutput) |> Vector.toList |> String.intercalate("\n")
            case Stage.Vertex   => ""
        };
        let preprocessor = pre |> Vector.map(Ast.renderPreprocessor) |> Vector.toList |> String.intercalate("\n");
        let uniforms = uni |> Vector.map(Ast.renderUniform) |> Vector.toList |> String.intercalate("\n");
        let varyings = vry |> Vector.map(Ast.renderVarying) |> Vector.toList |> String.intercalate("\n");
        let topLevels = top |> Vector.map(Ast.renderTopLevel) |> Vector.toList |> String.intercalate("\n\n");
        let globals = gbl |> Vector.map(Ast.renderGlobal) |> Vector.toList |> String.intercalate("\n");
        let body = bod |> Vector.flatMap(Ast.renderStmt) |> Vector.map(line -> "    ${line}") |> Vector.toList |> String.intercalate("\n");
        let parts = List.filter(s -> not String.isEmpty(s), List#{
            preamble,
            preprocessor,
            precision,
            uniforms,
            attributes,
            varyings,
            outputs,
            topLevels,
            globals,
            "void main() {",
            body,
            "}"
        });
        String.unlines(parts)

    ///
    /// Renders GLSL 4.20 core shader with support for extensions and includes.
    ///
    pub def renderStage420(stage: Stage, src: ShaderSource): String =
        let {preprocessor = pre, uniforms = uni, attributes = att, varyings = vry, outputs = out, topLevels = top, globals = gbl, body = bod} = src;
        let preamble = "#version 420 core";
        let precision = "";
        let attributes = match stage {
            case Stage.Vertex   => att |> Vector.map(Ast.renderAttribute) |> Vector.toList |> String.intercalate("\n")
            case Stage.Fragment => ""
        };
        let outputs = match stage {
            case Stage.Fragment => out |> Vector.map(Ast.renderOutput) |> Vector.toList |> String.intercalate("\n")
            case Stage.Vertex   => ""
        };
        let preprocessor = pre |> Vector.map(Ast.renderPreprocessor) |> Vector.toList |> String.intercalate("\n");
        let uniforms = uni |> Vector.map(Ast.renderUniform) |> Vector.toList |> String.intercalate("\n");
        let varyings = vry |> Vector.map(Ast.renderVarying) |> Vector.toList |> String.intercalate("\n");
        let topLevels = top |> Vector.map(Ast.renderTopLevel) |> Vector.toList |> String.intercalate("\n\n");
        let globals = gbl |> Vector.map(Ast.renderGlobal) |> Vector.toList |> String.intercalate("\n");
        let body = bod |> Vector.flatMap(Ast.renderStmt) |> Vector.map(line -> "    ${line}") |> Vector.toList |> String.intercalate("\n");
        let parts = List.filter(s -> not String.isEmpty(s), List#{
            preamble,
            preprocessor,
            precision,
            uniforms,
            attributes,
            varyings,
            outputs,
            topLevels,
            globals,
            "void main() {",
            body,
            "}"
        });
        String.unlines(parts)
}
