/**
 * Create an instance of Object, with no prototype.
 * On this object, define the property "wheels".
 */
const vehicle = Object.create(null);
Object.assign(vehicle, {wheels: 4});

/**
 *  Create a second object, with "vehicle" as
 * its prototype. On this object, define
 * the property "model".
 */
const honda = Object.create(vehicle);
Object.assign(honda, {model: "Honda"});

/**
 * Returns true after finding the "wheels"
 * property in the prototype chain of "honda".
 */
console.log("wheels" in honda)

/**
 * Returns true after finding the "model"
 * property directly on "honda".
*/
console.log("model" in honda)

/**
 * Returns false after not finding the "foobar"
 * property on "honda", or in its prototype chain.
 */
console.log("foobar" in honda)
