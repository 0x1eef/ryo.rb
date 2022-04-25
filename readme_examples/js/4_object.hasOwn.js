/**
 * Create an instance of Object, with no prototype.
 */
ryo = Object.create(null, {foo: {value: "foo"}});

/**
 * Create a second object, with the "ryo" object as
 * its prototype.
 */
ryo2 = Object.create(ryo, {bar: {value: "bar"}});


/**
 * Returns false
 */
console.log(Object.hasOwn(ryo2, "foo"));

/**
 * Returns true
 */
console.log(Object.hasOwn(ryo2, "bar"));
