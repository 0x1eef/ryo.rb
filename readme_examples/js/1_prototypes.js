/**
 * Creates an instance of Object, with no prototype.
 * On this object, define the properties "planet", and
 * "greet" using Object.assign().
 */
const person = Object.create(null);
Object.assign(person, {
  planet: 'Earth',
  greet () {
    const greeting = `${this.name} asks: have you tried ${this.language} ? ` +
                     `It is popular on my home planet, ${this.planet}.`;
    console.log(greeting);
  }
});

/**
 * Create a second object, with "person" as
 * its prototype. On this object, define the
 * properties "name" and "language" using
 * Object.assign().
 */
const larry = Object.create(person, {
  name: {value: 'Larry Wall'},
  language: {value: 'Perl'}
});

/**
 * Find matches directly on the "larry"
 * object.
 */
larry.name;     // => "Larry Wall"
larry.language; // => "Perl"

/**
 * Find matches in the prototype chain.
 */
larry.planet;  // => "Earth"
larry.greet(); // => "Larry Wall asks: have you tried Perl? ..."

/**
 * Create a second object, with "larry" as
 * its prototype. On this object, define
 * the properties "name" and "language" using
 * Object.assign().
 */
const matz = Object.create(larry, {
  name: {value: 'Yukihiro Matsumoto'},
  language: {value: 'Ruby', configurable: true}
});

/**
 * Find matches directly on the "matz"
 * object.
 */
matz.name;     // => "Yukihiro Matsumoto"
matz.language; // => "Ruby"

/**
 * Find matches in the prototype chain.
 */
matz.planet;  // => "Earth"
matz.greet(); // => "Yukihiro Matsumoto asks: have you tried Ruby? ..."

/**
 Delete the "language" property from matz,
 and find it on the larry prototype instead
*/
delete matz.language;
matz.greet(); // => "Yukihiro Matsumoto asks: have you tried Perl? ..."
