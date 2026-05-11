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

    use Glsl.Build.ShaderSource
    use Glsl.Stage.Stage

    pub def renderStage(stage: Stage, src: ShaderSource): String =
        let preamble = "#version 300 es";
        let precision = match stage {
            case Stage.Fragment => "precision highp float;"
            case Stage.Vertex   => ""
        };
        let attributes = match stage {
            case Stage.Vertex   => Vector.join("\n", src#attributes)
            case Stage.Fragment => ""
        };
        let outputs = match stage {
            case Stage.Fragment => Vector.join("\n", src#outputs)
            case Stage.Vertex   => ""
        };
        let uniforms = Vector.join("\n", src#uniforms);
        let varyings = Vector.join("\n", src#varyings);
        let extensions = Vector.join("\n", src#extensions);
        let defines = Vector.join("\n", src#defines);
        let includes = Vector.join("\n", src#includes);
        let functions = Vector.join("\n", src#functions);
        let globals = Vector.join("\n", src#globals);
        let body = src#body |> Vector.map(line -> "    ${line}") |> Vector.join("\n");
        let parts = List.filter(s -> not String.isEmpty(s), List#{
            preamble,
            extensions,
            defines,
            includes,
            precision,
            uniforms,
            attributes,
            varyings,
            outputs,
            functions,
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
        let preamble = "#version 420 core";
        let precision = "";
        let attributes = match stage {
            case Stage.Vertex   => Vector.join("\n", src#attributes)
            case Stage.Fragment => ""
        };
        let outputs = match stage {
            case Stage.Fragment => Vector.join("\n", src#outputs)
            case Stage.Vertex   => ""
        };
        let uniforms = Vector.join("\n", src#uniforms);
        let varyings = Vector.join("\n", src#varyings);
        let extensions = Vector.join("\n", src#extensions);
        let defines = Vector.join("\n", src#defines);
        let includes = Vector.join("\n", src#includes);
        let functions = Vector.join("\n", src#functions);
        let globals = Vector.join("\n", src#globals);
        let body = src#body |> Vector.map(line -> "    ${line}") |> Vector.join("\n");
        let parts = List.filter(s -> not String.isEmpty(s), List#{
            preamble,
            extensions,
            defines,
            includes,
            precision,
            uniforms,
            attributes,
            varyings,
            outputs,
            functions,
            globals,
            "void main() {",
            body,
            "}"
        });
        String.unlines(parts)
}
