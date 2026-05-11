///
/// `Glsl.Stage` — vertex / fragment distinction.
///
pub mod Glsl.Stage {

    pub enum Stage with Eq, ToString {
        case Vertex
        case Fragment
    }
}
