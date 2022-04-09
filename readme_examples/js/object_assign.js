const fruit = Object.create(null);
const apple = Object.create(fruit);
Object.assign(fruit, apple, { sour: true });

console.log(apple.sour); // => true
console.log(fruit.sour); // => true
