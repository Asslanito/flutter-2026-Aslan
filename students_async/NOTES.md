# Practice 10: The Data Arrives Later: NOTES

## Level 1: order of events

Experiment in `main()` before `runApp` (removed afterwards):

```dart
print('A');
Future.delayed(const Duration(seconds: 2), () => print('B'));
print('C');
final api = FakeApi();
api.fetchStudents().then((l) => print('${l.length} students'));
```

**Predicted:** `A`, `C`, (first frame is drawn), then ~2 s later `B` and `6 students`.
`main()` runs to the end first; the timer and the fake request are events the loop handles later.

**Actual:** `A`, `C`, first frame of the app, ~2 s later `B` and `6 students`. Matches the prediction. Nothing waited.

Calling `fetchStudents()` three times in a row from `main()`; the third prints:

```
Unhandled Exception: Instance of 'NoConnectionException'
```

and the app keeps running. Nobody awaited that Future: this is Level 5.

Replacing `await Future.delayed(...)` with `sleep(const Duration(seconds: 2))` (dart:io): the first frame is
delayed by 2 s. The loop is blocked, not waiting. `await` put back.

## Level 2: setState after dispose

Removed both `if (!mounted) return;` guards, opened the screen, pressed Back within 2 s:

```
setState() called after dispose(): _StudentsScreenState#xxxxx(lifecycle state: defunct, not mounted)
```

With the guards back, the console stays silent: the response arrived at a State that was gone, and `mounted` said so.

## Level 3: FutureBuilder

- `_future` as a field: one `fetchStudents #1`, flipping the Switch ten times never reloads or flickers.
- `future: _api.fetchStudents()` inline in `build`: spinner on every flip, console prints `#2 #3 #4 …`, the third fails.
- Swapping the first two branches (`hasData` first): spinner forever when the request fails. Restored.

## Level 4: countdown

- **Without `_sub.cancel()` (version B):** Back at 7 → one second later `setState() called after dispose()`, and
  the console keeps printing `tick 6`, `tick 5` … `tick 0` with nobody on screen. That is the leak.
- **Version A (StreamBuilder):** no `cancel()` anywhere in my code, Back at 7: the console stops at `tick 7`.
  StreamBuilder cancelled for me.
- **With `_sub.cancel()` (version B):** Back at 7, the console stops at `tick 7`.

## Level 5: errors that do not vanish

Naive version: `onPressed: () { _api.save(n); Navigator.pop(context); }`

`flutter analyze` flags it with `unawaited_futures`. The user saw a success (the screen popped), while the console says:

```
Unhandled Exception: Bad state: server rejected 6
```

Honest version: `await` + `try / on StateError`, `context.mounted` after the await, pop only on success,
message in a SnackBar only on failure, `_saving` disables the button and shows a spinner: two fast taps send one request.

Note: `save` counts calls in a static field, so the server remembers across screens: save #1 succeeds (pops),
save #2 anywhere in the app is rejected.
