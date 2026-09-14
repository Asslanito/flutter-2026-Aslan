# Practice 2 — Dart Domain Modeling

**Aslan · Mobile Development · 2026**

A library catalogue in pure Dart, covering classes, inheritance, null safety,
collections and Dart 3 patterns. The programme loads six books, handles incomplete
records and prints a catalogue report with statistics.

## Run

From the repository root, using Dart 3.8 or later:

```sh
dart pub get
dart run lib/week02/main.dart
```

## Project files

| File | Contents |
| --- | --- |
| [data.dart](lib/week02/data.dart) | Original starter data: six books, including two incomplete entries |
| [models.dart](lib/week02/models.dart) | Author, Genre, Book, LibraryItem, Magazine, Borrowable and Ghost |
| [catalogue.dart](lib/week02/catalogue.dart) | Library, nullable lookup, cached report and collection queries |
| [shelf_state.dart](lib/week02/shelf_state.dart) | Sealed states, exhaustive pattern matching and record statistics |
| [main.dart](lib/week02/main.dart) | Runnable demonstration of all five levels |
| [week02_test.dart](test/week02_test.dart) | Twelve tests for the models, queries and edge cases |

## Expected results

| Query | Result |
| --- | --- |
| Books | 6 |
| Total pages | 2,219 |
| Average pages | 369.83 |
| Books published after 2010 | The Pragmatic Programmer, Refactoring, Broken Record |
| Genres | Craft, Theory, Unknown |
| Missing title | `null` |
| Missing country | `unknown` |

The demonstration also includes a Magazine and a Ghost to show the mixed
hierarchy. Book statistics include only books. See the
[complete sample output](docs/practice02-output.txt).

## Checks

```sh
dart analyze
dart test
```

Expected: `No issues found!` and all 12 tests passing. Tests cover incomplete and
invalid input, empty catalogues, repeated authors, immutable copies, report cache
invalidation, hierarchy behaviour and all three shelf states.

## Model conventions

- Missing pages default to zero and count towards the average.
- `isLong` means more than 400 pages; `isOld` means more than 20 years old.
- `copyWith` preserves omitted fields; `clearDescription: true` clears the description.
- `Library.open()` sets the opening time once. Use `add()` to update the catalogue
  and invalidate its cached report.

<details>
<summary>Note about the supplied starter data</summary>

The handout asks for `data.dart` to be copied exactly, including its
`Map<String, dynamic>` declaration, while also banning `dynamic` outside the
factory parameter. The starter data is preserved verbatim. The only other
explicit `dynamic` is the required `Book.fromJson` parameter. All model fields,
locals and query results are typed, and `lib/week02/` contains no exclamation marks.

</details>
