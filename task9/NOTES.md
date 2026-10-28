# Practice 9

## Level 1: Lift it up

Adding the total to the badge touched 2 constructors in 2 files: `BooksScreen` in `lib/books_screen.dart` and `CartBadge` in `lib/cart_badge.dart`.

One Add tap rebuilt the BooksScreen and its 6 rows: 7 build log lines.

## Level 3: Provider

- `context.watch<Cart>()` from an Add callback: “Tried to listen to a value exposed with provider, from outside of the widget tree.” It fails because callbacks must use `read`.
- `context.read<Cart>().count` in the badge: no error, but the badge remains at 0 because `read` does not subscribe to changes.

## Level 4: Rebuilds

- With `watch` in the badge, three quantity increments rebuild the badge 3 times.
- With `select` on `count`, the same three increments rebuild the badge 0 times because the count is unchanged.
- Removing an item changes the count and rebuilds the badge once.

## Where does it live?

- Cart: provided above `MaterialApp`; both routes need the same shared state.
- Search text: ephemeral state in the Books screen; no other screen needs the current query.
- Cart total expanded or collapsed: ephemeral state in the Cart screen; it controls only that view.
- Theme mode: lifted above `MaterialApp` if the app adds a dark-mode switch; it affects every route.
