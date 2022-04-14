/**
 * Create an instance of Object, with no prototype.
 * On this object,  define the properties "sour" and
 * "eat" using Object.assign().
 */
const fruit = Object.create(null);
Object.assign(fruit, {
  sour: false,
  eat() { return `Eating a ${this.name}`; }
});

/**
 * Create a second object, with "fruit" as
 * its prototype. On this object, define
 * the properties "name" and "color" using
 * Object.assign().
 */
const apple = Object.create(fruit);
Object.assign(apple, { name: 'Apple', color: 'green' });

/**
 * Find matches directly on the "apple"
 * object.
 */
console.log(apple.name);
console.log(apple.color);

/**
 * Find matches in the prototype chain.
 */
console.log(apple.sour);
console.log(apple.eat());

/**
 * Create a second object, with "apple" as
 * its prototype. On this object, define
 * the properties "name" and "sour" using
 * Object.assign().
 */
const sourApple = Object.create(apple);
Object.assign(sourApple, { name: 'Sour Apple', sour: true });

/**
 * Find matches directly on the "sourApple"
 * object.
 */
console.log(sourApple.name);
console.log(sourApple.sour);

/**
 * Find matches in the prototype chain.
 */
console.log(sourApple.color);
console.log(sourApple.eat());
