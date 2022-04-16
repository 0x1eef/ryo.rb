/**
 * Create an instance of Object, with
 * no prototype.
 */
const fruit = Object.create(null)

/** *
 * Merge {sour:true} into "fruit".
 */
Object.assign(fruit, {sour: true})

console.log(fruit.sour) // => true
