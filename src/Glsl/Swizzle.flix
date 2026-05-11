///
/// `Glsl.Swizzle` — typed swizzle read helpers.
///
/// Each swizzle is implemented as a trait to ensure that e.g. `.z` can
/// only be called on `Vec3` or `Vec4`, and `.w` only on `Vec4`.
///
/// We prioritize the most common swizzles here (Priority 3 in
/// `EFFORT_NEEDED.md`). Exotic permutations can be reached via the
/// `Expr.Field` escape hatch.
///
pub mod Glsl.Swizzle {

    use Glsl.Expr.Expr
    use Glsl.Expr.boxed
    use Glsl.Types.Vec2
    use Glsl.Types.Vec3
    use Glsl.Types.Vec4

    // --- 1-component swizzles (float results) ---

    pub trait HasX[t] { pub def getX(e: Expr[t]): Expr[Float32] }
    instance HasX[Vec2] { pub def getX(e: Expr[Vec2]): Expr[Float32] = Expr.Field(boxed(e), "x") }
    instance HasX[Vec3] { pub def getX(e: Expr[Vec3]): Expr[Float32] = Expr.Field(boxed(e), "x") }
    instance HasX[Vec4] { pub def getX(e: Expr[Vec4]): Expr[Float32] = Expr.Field(boxed(e), "x") }
    pub def x(e: Expr[t]): Expr[Float32] with HasX[t] = HasX.getX(e)

    pub trait HasY[t] { pub def getY(e: Expr[t]): Expr[Float32] }
    instance HasY[Vec2] { pub def getY(e: Expr[Vec2]): Expr[Float32] = Expr.Field(boxed(e), "y") }
    instance HasY[Vec3] { pub def getY(e: Expr[Vec3]): Expr[Float32] = Expr.Field(boxed(e), "y") }
    instance HasY[Vec4] { pub def getY(e: Expr[Vec4]): Expr[Float32] = Expr.Field(boxed(e), "y") }
    pub def y(e: Expr[t]): Expr[Float32] with HasY[t] = HasY.getY(e)

    pub trait HasZ[t] { pub def getZ(e: Expr[t]): Expr[Float32] }
    instance HasZ[Vec3] { pub def getZ(e: Expr[Vec3]): Expr[Float32] = Expr.Field(boxed(e), "z") }
    instance HasZ[Vec4] { pub def getZ(e: Expr[Vec4]): Expr[Float32] = Expr.Field(boxed(e), "z") }
    pub def z(e: Expr[t]): Expr[Float32] with HasZ[t] = HasZ.getZ(e)

    pub trait HasW[t] { pub def getW(e: Expr[t]): Expr[Float32] }
    instance HasW[Vec4] { pub def getW(e: Expr[Vec4]): Expr[Float32] = Expr.Field(boxed(e), "w") }
    pub def w(e: Expr[t]): Expr[Float32] with HasW[t] = HasW.getW(e)

    // Color aliases
    pub trait HasR[t] { pub def getR(e: Expr[t]): Expr[Float32] }
    instance HasR[Vec2] { pub def getR(e: Expr[Vec2]): Expr[Float32] = Expr.Field(boxed(e), "r") }
    instance HasR[Vec3] { pub def getR(e: Expr[Vec3]): Expr[Float32] = Expr.Field(boxed(e), "r") }
    instance HasR[Vec4] { pub def getR(e: Expr[Vec4]): Expr[Float32] = Expr.Field(boxed(e), "r") }
    pub def r(e: Expr[t]): Expr[Float32] with HasR[t] = HasR.getR(e)

    pub trait HasG[t] { pub def getG(e: Expr[t]): Expr[Float32] }
    instance HasG[Vec2] { pub def getG(e: Expr[Vec2]): Expr[Float32] = Expr.Field(boxed(e), "g") }
    instance HasG[Vec3] { pub def getG(e: Expr[Vec3]): Expr[Float32] = Expr.Field(boxed(e), "g") }
    instance HasG[Vec4] { pub def getG(e: Expr[Vec4]): Expr[Float32] = Expr.Field(boxed(e), "g") }
    pub def g(e: Expr[t]): Expr[Float32] with HasG[t] = HasG.getG(e)

    pub trait HasB[t] { pub def getB(e: Expr[t]): Expr[Float32] }
    instance HasB[Vec3] { pub def getB(e: Expr[Vec3]): Expr[Float32] = Expr.Field(boxed(e), "b") }
    instance HasB[Vec4] { pub def getB(e: Expr[Vec4]): Expr[Float32] = Expr.Field(boxed(e), "b") }
    pub def b(e: Expr[t]): Expr[Float32] with HasB[t] = HasB.getB(e)

    pub trait HasA[t] { pub def getA(e: Expr[t]): Expr[Float32] }
    instance HasA[Vec4] { pub def getA(e: Expr[Vec4]): Expr[Float32] = Expr.Field(boxed(e), "a") }
    pub def a(e: Expr[t]): Expr[Float32] with HasA[t] = HasA.getA(e)

    // Texcoord aliases
    pub trait HasS[t] { pub def getS(e: Expr[t]): Expr[Float32] }
    instance HasS[Vec2] { pub def getS(e: Expr[Vec2]): Expr[Float32] = Expr.Field(boxed(e), "s") }
    instance HasS[Vec3] { pub def getS(e: Expr[Vec3]): Expr[Float32] = Expr.Field(boxed(e), "s") }
    instance HasS[Vec4] { pub def getS(e: Expr[Vec4]): Expr[Float32] = Expr.Field(boxed(e), "s") }
    pub def s(e: Expr[t]): Expr[Float32] with HasS[t] = HasS.getS(e)

    pub trait HasT[t] { pub def getT(e: Expr[t]): Expr[Float32] }
    instance HasT[Vec2] { pub def getT(e: Expr[Vec2]): Expr[Float32] = Expr.Field(boxed(e), "t") }
    instance HasT[Vec3] { pub def getT(e: Expr[Vec3]): Expr[Float32] = Expr.Field(boxed(e), "t") }
    instance HasT[Vec4] { pub def getT(e: Expr[Vec4]): Expr[Float32] = Expr.Field(boxed(e), "t") }
    pub def t(e: Expr[t]): Expr[Float32] with HasT[t] = HasT.getT(e)

    pub trait HasP[t] { pub def getP(e: Expr[t]): Expr[Float32] }
    instance HasP[Vec3] { pub def getP(e: Expr[Vec3]): Expr[Float32] = Expr.Field(boxed(e), "p") }
    instance HasP[Vec4] { pub def getP(e: Expr[Vec4]): Expr[Float32] = Expr.Field(boxed(e), "p") }
    pub def p(e: Expr[t]): Expr[Float32] with HasP[t] = HasP.getP(e)

    pub trait HasQ[t] { pub def getQ(e: Expr[t]): Expr[Float32] }
    instance HasQ[Vec4] { pub def getQ(e: Expr[Vec4]): Expr[Float32] = Expr.Field(boxed(e), "q") }
    pub def q(e: Expr[t]): Expr[Float32] with HasQ[t] = HasQ.getQ(e)


    // --- 2-component swizzles (Vec2 results) ---

    pub trait HasXY[t] { pub def getXY(e: Expr[t]): Expr[Vec2] }
    instance HasXY[Vec2] { pub def getXY(e: Expr[Vec2]): Expr[Vec2] = Expr.Field(boxed(e), "xy") }
    instance HasXY[Vec3] { pub def getXY(e: Expr[Vec3]): Expr[Vec2] = Expr.Field(boxed(e), "xy") }
    instance HasXY[Vec4] { pub def getXY(e: Expr[Vec4]): Expr[Vec2] = Expr.Field(boxed(e), "xy") }
    pub def xy(e: Expr[t]): Expr[Vec2] with HasXY[t] = HasXY.getXY(e)

    pub trait HasXZ[t] { pub def getXZ(e: Expr[t]): Expr[Vec2] }
    instance HasXZ[Vec3] { pub def getXZ(e: Expr[Vec3]): Expr[Vec2] = Expr.Field(boxed(e), "xz") }
    instance HasXZ[Vec4] { pub def getXZ(e: Expr[Vec4]): Expr[Vec2] = Expr.Field(boxed(e), "xz") }
    pub def xz(e: Expr[t]): Expr[Vec2] with HasXZ[t] = HasXZ.getXZ(e)

    pub trait HasYZ[t] { pub def getYZ(e: Expr[t]): Expr[Vec2] }
    instance HasYZ[Vec3] { pub def getYZ(e: Expr[Vec3]): Expr[Vec2] = Expr.Field(boxed(e), "yz") }
    instance HasYZ[Vec4] { pub def getYZ(e: Expr[Vec4]): Expr[Vec2] = Expr.Field(boxed(e), "yz") }
    pub def yz(e: Expr[t]): Expr[Vec2] with HasYZ[t] = HasYZ.getYZ(e)

    pub trait HasZW[t] { pub def getZW(e: Expr[t]): Expr[Vec2] }
    instance HasZW[Vec4] { pub def getZW(e: Expr[Vec4]): Expr[Vec2] = Expr.Field(boxed(e), "zw") }
    pub def zw(e: Expr[t]): Expr[Vec2] with HasZW[t] = HasZW.getZW(e)

    pub trait HasRG[t] { pub def getRG(e: Expr[t]): Expr[Vec2] }
    instance HasRG[Vec2] { pub def getRG(e: Expr[Vec2]): Expr[Vec2] = Expr.Field(boxed(e), "rg") }
    instance HasRG[Vec3] { pub def getRG(e: Expr[Vec3]): Expr[Vec2] = Expr.Field(boxed(e), "rg") }
    instance HasRG[Vec4] { pub def getRG(e: Expr[Vec4]): Expr[Vec2] = Expr.Field(boxed(e), "rg") }
    pub def rg(e: Expr[t]): Expr[Vec2] with HasRG[t] = HasRG.getRG(e)

    pub trait HasBA[t] { pub def getBA(e: Expr[t]): Expr[Vec2] }
    instance HasBA[Vec4] { pub def getBA(e: Expr[Vec4]): Expr[Vec2] = Expr.Field(boxed(e), "ba") }
    pub def ba(e: Expr[t]): Expr[Vec2] with HasBA[t] = HasBA.getBA(e)

    pub trait HasST[t] { pub def getST(e: Expr[t]): Expr[Vec2] }
    instance HasST[Vec2] { pub def getST(e: Expr[Vec2]): Expr[Vec2] = Expr.Field(boxed(e), "st") }
    instance HasST[Vec3] { pub def getST(e: Expr[Vec3]): Expr[Vec2] = Expr.Field(boxed(e), "st") }
    instance HasST[Vec4] { pub def getST(e: Expr[Vec4]): Expr[Vec2] = Expr.Field(boxed(e), "st") }
    pub def st(e: Expr[t]): Expr[Vec2] with HasST[t] = HasST.getST(e)

    pub trait HasPQ[t] { pub def getPQ(e: Expr[t]): Expr[Vec2] }
    instance HasPQ[Vec4] { pub def getPQ(e: Expr[Vec4]): Expr[Vec2] = Expr.Field(boxed(e), "pq") }
    pub def pq(e: Expr[t]): Expr[Vec2] with HasPQ[t] = HasPQ.getPQ(e)


    // --- 3-component swizzles (Vec3 results) ---

    pub trait HasXYZ[t] { pub def getXYZ(e: Expr[t]): Expr[Vec3] }
    instance HasXYZ[Vec3] { pub def getXYZ(e: Expr[Vec3]): Expr[Vec3] = Expr.Field(boxed(e), "xyz") }
    instance HasXYZ[Vec4] { pub def getXYZ(e: Expr[Vec4]): Expr[Vec3] = Expr.Field(boxed(e), "xyz") }
    pub def xyz(e: Expr[t]): Expr[Vec3] with HasXYZ[t] = HasXYZ.getXYZ(e)

    pub trait HasXYW[t] { pub def getXYW(e: Expr[t]): Expr[Vec3] }
    instance HasXYW[Vec4] { pub def getXYW(e: Expr[Vec4]): Expr[Vec3] = Expr.Field(boxed(e), "xyw") }
    pub def xyw(e: Expr[t]): Expr[Vec3] with HasXYW[t] = HasXYW.getXYW(e)

    pub trait HasRGB[t] { pub def getRGB(e: Expr[t]): Expr[Vec3] }
    instance HasRGB[Vec3] { pub def getRGB(e: Expr[Vec3]): Expr[Vec3] = Expr.Field(boxed(e), "rgb") }
    instance HasRGB[Vec4] { pub def getRGB(e: Expr[Vec4]): Expr[Vec3] = Expr.Field(boxed(e), "rgb") }
    pub def rgb(e: Expr[t]): Expr[Vec3] with HasRGB[t] = HasRGB.getRGB(e)


    // --- 4-component swizzles (Vec4 results) ---

    pub trait HasRGBA[t] { pub def getRGBA(e: Expr[t]): Expr[Vec4] }
    instance HasRGBA[Vec4] { pub def getRGBA(e: Expr[Vec4]): Expr[Vec4] = Expr.Field(boxed(e), "rgba") }
    pub def rgba(e: Expr[t]): Expr[Vec4] with HasRGBA[t] = HasRGBA.getRGBA(e)

}
