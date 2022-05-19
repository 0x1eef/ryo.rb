/**
 * Create an instance of Object, with no prototype.
 */
const book = Object.create(null);

/**
 * Merge {pageCount: 10} into "book",
 * then merge {title: "..."} into "book",
 * and finally merge {pageCount: 20} into
 * "book".
 */
Object.assign(
  book,
  {pageCount: 10},
  {title: "The mysterious case of the believer"},
  {pageCount: 20}
);

/**
 * Prints 20
 */
console.log(book.pageCount);

/**
 * Prints: The mysterious case of the believer
 */
console.log(book.title);
