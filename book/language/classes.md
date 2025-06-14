# Classes
Jig is not an object oriented programming language. As such classes in Jig behave differently than classes in other languages according to the following notes.

## Note on private
The `private` keyword actually doesn't do anything at runtime. It exists purely for documentation and linting purposes.

## Note on top level field initializers
Top level field initializers just get copied down into the top of the class's constructor at compile time. 

## Note on parent class constructors
A parent class's constructor is not called automatically at the top of the child's constructor.

## Note on constructors
A class can't have multiple constructors

## Note on tear offs
For performance and implementation reasons, methods of Jig classes are not bound to an instance of that classes. This means the following is NOT allowed
```ts
class Person {
    name: String;
    new(this.name);
    sayHi() {
        println(name);
    }
}

var tim = new Person("Tim");
var timSayHi = tim.sayHi;
timSayHi(); // prints out "Tim"
```
Instead you can do
```ts
var timSayHi = () => { tim.sayHi() };
timSayHi(); // prints out "Tim"
```

## Classes
Classes are created like so:
```ts
class Animal {
    static const needsOxygen = true; // static makes a property/method belong to class.static rather than class

    age: i32 = 0; // variable declarations
    private name; // private variables
    
    new(n: String) { // constructor
        name = n; // define object properties
        getName(); // call methods
        this.getName(); // properties/methods can also be accessed using the `this` keyword
    }
    
    getName() String { // methods
        return this.name;
    }

    free() {
        // destructor
    }
}
```

## Constructor and Destructor
The constructor of a class is written as a method using `new` as an identifier. The destructor of a class is written using `free` as an identifier. Using the `free` keyword like so `free someInstance` on an instance will call the instance's `free` method if it exists and then deallocate the object from memory. When the garbage collector deallocates an object its free method is not called. Calling a object's free method does not deallocate the object from memory. Calling `myClass().new()` is the same as `new myClass()`. By default properties/methods are public, but can be made private using the `private` keyword. You can shorthand initializing properties of the class in the constructor by using `this.propertyName` in the parameters of the constructor.
```ts
class Person {
    name: String;
    new(this.name);
}

// is same as 
class Person {
    name: String;
    new(name: String) {
        this.name = name;
    }
}
```

## Inheritance
Multiple inheritance is supported. If a class has two parent classes with the same property/method it will inherit from the last parent. By default all properties of classes are `var`. The constructors of the parent classes will be available to be called from the class's constructor. It is not necessary to call a parent's constructor. If a parent's constructor is not called then the code in the parents constructor is not executed. However, the properties and methods from the parent class will still exist on the child instance. Accessing a property that doesn't exist on on Object will throw an error.

Properties of an Object are accessed using the dot operator `.`
```ts
class LandAnimal {
    thing = 0;
    new(num) {
        thing = num;
    }
    move() { println("Walk"); }
}
class WaterAnimal {
    thing = 2;
    new() {
        
    }
    move() { println("Swim"); }
}
```
```ts
class Platypus extends LandAnimal, WaterAnimal {
    new() {
        this.thing // returns 2 because WaterAnimal is the last parent class
        super.LandAnimal(1); // calls LandAnimal's constructor
        this.thing // returns 1 because LandAnimal's constructor updated thing
    }
}
new Platypus().move(); // prints "Swim" because WaterAnimal is the last class Platypus is extended from
new Platypus().thing // 1
```
Using `inherit … from …` and `inherit … from … as …` you can inherit a property/method from any class resulting in very powerful multi inheritance. This can also be used to overwrite the default behavior of inheriting the property/method from the class at the end of the extends list.
```ts
class Platypus extends WaterAnimal, LandAnimal {
    new() {
        super.WaterAnimal(1);
        super.LandAnimal();
    }
    inherit move from WaterAnimal;
}
new Platypus().move(); // prints "Swim"
```
```ts
class Platypus extends WaterAnimal, LandAnimal {
    new() {
        super.WaterAnimal(1);
        super.LandAnimal();
    }
    inherit move from LandAnimal as walk;
    inherit move from WaterAnimal as swim;
}
new Platypus().walk(); // prints "Walk"
new Platypus().swim(); // prints "Swim"
new Platypus().thing // 1
```
When inheriting multiple properties from one class you can use a comma separated list
```ts
class Parent {
    new() {}
    a() {}
    b() {}
    c() {}
    d() {}
}
class Child {
    new() {}
    // Because we are only using "inherit a, b, c from Parent" only properties a, b, and c are inherited from Parent.
    // Method d is not inherited because we haven't used "extends Parent". We also can NOT call Parent's constructor.
    inherit a, b, c from Parent as x, y, z;
}
```
A class can be created without a constructor. This simply defaults to an empty constructor that accepts no arguments being implicitly created.

## Operator Overloading
Operator overloading on classes is done by adding the operator symbol as the identifier of a method on the class. It will accept one value as an argument which will be the value that is being operated on with the instance.

The order in which the operands are operated on does matter. However if the first operand doesn't have any overloaded operators the VM will check for overloaded operators on the second operand before throwing a type error. The operator overloader method has a second parameter that is true if the object is the right operand in the computation.

```ts
class vec3 {
    [x, y, z]: f32;
    new(this.x, this.y, this.z);

    +(value: any) {
        if (typeof value == vec3):
            return new vec3(x + value.x, y + value.y, z + value.z);
        else if (typeof value == f32):
            return new vec3(x + value, y + value, z + value);
        else:
            throw "vec3 can only be added with vectors or f32"
    }

    -(value: any, isRightOperand: bool) {
        if (typeof value == vec3):
            if (isRightOperand):
                return new vec3(value.x - x, value.y - y, value.z - z);
            return new vec3(x - value.x, y - value.y, z - value.z);
        else if (typeof value == f32):
            if (isRightOperand):
                new vec3(value - x, value - y, value - z);
            return new vec3(x - value, y - value, z - value);
        else:
            throw "vec3 can only be added with vectors or f32"
    }
}

// results in vec3(5, 7, 9)
var myVec = vec3(1, 2, 3) + vec3(4, 5, 6); 

// results in vec3(1, 1, 1)
var myVec = vec3(0, 0, 0) + 1; 

// results in vec3(-1, -1, -1)
var myVec = vec3(0, 0, 0) - 1; 

// results in vec3(1, 1, 1)
var myVec = 1 - vec3(0, 0, 0); 

// !!!!! ERROR !!!!! throws "vec3 can only be added with vectors or f32"
var myVec = vec3(0, 0, 0) + "Hello World"; 
```

