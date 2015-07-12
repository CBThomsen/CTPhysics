package CTPhysics.Math {
    public class CTVector {
        public var x:Number
        public var y:Number
         
        public function CTVector(a,b) {
            x = a;
            y = b;
        }
        public function leftNormal() {
           var tempX = x
            x = y
            y = tempX * -1
            return  this.normalize();
        }
        public function rightNormal() {
           var tempX = x
            x = y * -1
            y = tempX
            return  this.normalize();
        }
        public function sum(otherVector:CTVector):CTVector {
            x += otherVector.x;
            y += otherVector.y;
            return this;
        }
        public function subtract(otherVector:CTVector):CTVector {
            x -= otherVector.x
            y -= otherVector.y
            return this
        }
        public function dot(otherVector:CTVector):Number {
                return (x * otherVector.x) + (y * otherVector.y)
        }
        public function vectorCrossProduct(otherVector:CTVector):Number {
                return (x * otherVector.y) - (y * otherVector.x)
        }
        public function times(num:Number) : CTVector {
            x *= num
            y *= num
            return this
        }
        public function magnitude() : Number {
                return Math.sqrt((x * x) + (y * y));
        }
        public function normalize() :CTVector {
            var m:Number = magnitude()
            if(m != 0) {
                x /= m
                y /= m
            }

            return this
        }
        public function crossProduct(num:Number) {
            x *= -num
            y *= num
            return this
        }
        public function reverseCrossProduct(num:Number) {
            x *= num
            y *= -num
            return this
        }
        public function clone() {
            return new CTVector(x, y)
        }
    }
}