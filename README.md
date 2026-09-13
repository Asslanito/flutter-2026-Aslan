# Flutter 2026 — Aslan

Mobile Development coursework.

## Practice 1: Flutter installation and first run

`practice01/hello/` is the original Flutter counter app, generated with the stable
Flutter SDK. It is a separate Flutter package; the repository root is the pure
Dart package for Practice 2. Check and run the counter app from its own directory:

```sh
cd practice01/hello
flutter pub get
flutter analyze
flutter test
flutter emulators --launch Pixel_7_API_35
flutter run
```

Press `r` in the running terminal to hot reload. Local setup and verification
details are recorded in `docs/SETUP.md`.

## Practice 2: Dart Domain Modeling

A library catalogue written in pure Dart. This practice has no Flutter or widget
dependencies. Run the following commands from the repository root:

```sh
dart pub get
dart run lib/week02/main.dart
dart analyze
dart test
```

### Files and requirements

| File | Features |
| --- | --- |
| `lib/week02/data.dart` | The six original starter entries, copied verbatim |
| `lib/week02/models.dart` | Author, enhanced Genre enum, immutable Book, factory, getter, copyWith, LibraryItem, Magazine, Borrowable, Ghost |
| `lib/week02/catalogue.dart` | Nullable lookup, null-aware country lookup, late initialization, cached report, expression-based collection queries |
| `lib/week02/shelf_state.dart` | Exactly three sealed subtypes, exhaustive object-pattern switch, named record statistics |
| `lib/week02/main.dart` | Executable demonstration of all five levels |
| `test/week02_test.dart` | Incomplete input, empty catalogues, calculations, duplicate authors, cache invalidation, hierarchy and states |

### Expected results

- Six books; the optional Magazine and Ghost demonstrate the mixed catalogue.
- Books after 2010: The Pragmatic Programmer, Refactoring, Broken Record.
- Total pages: 2,219. Average over all six books: 369.83 (rounded for display).
- Missing pages default to zero and remain included in the average.
- Missing country displays `unknown`; missing genre becomes `Genre.unknown`.
- An absent title returns `null` without throwing.
- The display list ends with `(incomplete data)` because Broken Record has zero pages.
- A record with `count: 6` and `avgPages: 369.8333333333333` is printed.
- Empty, Ready and Broken are all described.

### Design notes

The brief does not define how old an item must be for `isOld`. This implementation
uses more than 20 years relative to the current year. `isLong` is strictly more
than 400 pages. `copyWith` preserves omitted values; `clearDescription: true`
explicitly clears the optional description.

`Library.open()` initializes `openedAt` once and safely ignores later calls.
Use `Library.add()` to update the collection and invalidate the cached report.
Book-only queries ignore magazines and ghost entries; the title query includes
every library item. A zero-seeded `fold` and an empty-list guard keep averages safe.

The handout contains one conflict: it requires the starter data to be copied
exactly, including `Map<String, dynamic>`, but also bans `dynamic` outside the
factory parameter. The supplied `data.dart` declaration is preserved as requested.
The only other occurrence is the required `Book.fromJson` parameter. All model
fields, locals and query results are typed. There are no exclamation marks anywhere
in `lib/week02/`.

### Language references

- [Classes and constructors](https://dart.dev/language/classes)
- [Null safety](https://dart.dev/null-safety/understanding-null-safety)
- [Iterable collections](https://dart.dev/codelabs/iterables)
- [Patterns](https://dart.dev/language/patterns)
