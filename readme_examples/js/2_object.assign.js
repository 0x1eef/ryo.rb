/**
 * Create an instance of Object, with
 * no prototype.
 */
const fruit = Object.create(null)

/**
 * Create another object, with "fruit"
 * as its prototype.
 */
const pineapple = Object.create(fruit)

/**
 * Merge {sour: true} into "pineapple", and then
 * merge "pineapple" into "fruit".
 */
Object.assign(fruit, pineapple, {sour: true})

console.log(fruit.sour)     // => true
console.log(pineapple.sour) // => true
