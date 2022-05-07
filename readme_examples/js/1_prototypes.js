/**
 * Creates an instance of Object, with no prototype.
 * On this object, define the properties "name", and
 * "description".
 */
const perl = Object.create(null);
Object.assign(perl, {
  name: 'Perl',
  description () { return `The ${this.name} programming language`; }
});

/**
 * Find matches directly on the "perl" object.
 */
console.log(perl.name);
console.log(perl.description());

/**
 * Create a second object, with "perl" as its prototype.
 */
const ruby = Object.create(perl, {name: {value: 'Ruby'}});

/**
 * Find matches directly on the "ruby" object.
 */
console.log(ruby.name); /* "Ruby" */

/**
 * Find matches in the prototype chain.
 */
console.log(ruby.description()) /* "The Ruby programming language"

/**
 * Create a second object, with "ruby" as its prototype.
 */
const crystal = Object.create(ruby, {name: {value: "Crystal", configurable: true}});

/**
 * Find matches directly on the "crystal" object.
 */
console.log(crystal.name); /* => "Crystal" */

/**
 * Find matches in the prototype chain.
 */
console.log(crystal.description()) /* "The Crystal programming language" */

/**
 Delete the "name" property from "crystal".
*/
delete crystal.name;
console.log(crystal.description());  /* "The Ruby programming language" */
