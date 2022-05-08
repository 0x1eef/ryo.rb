/**
 * Create an instance of Object, with no prototype.
 */
const fruit = Object.create(null)

/**
 * Create another object, with "fruit" as its
 * prototype.
 */
const pineapple = Object.create(fruit)

/**
 * Merge {delicious:true} into {sweet: true},
 * then merge the result of that merge into
 * pineapple, finally merge pineapple into fruit.
 */
Object.assign(fruit, pineapple, {sweet: true}, {delicious: true})

/**
 * Prints true (x2)
 */
console.log(fruit.sweet)
console.log(fruit.delicious)

/**
 * Prints true (x2)
 */
console.log(pineapple.sweet);
console.log(pineapple.delicious);
