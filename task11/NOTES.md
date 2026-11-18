# Practice 11 — NOTES

## Level 1: Postman
- `GET /users` → 200, `Content-Type: application/json; charset=utf-8`, a JSON **list** of 10 users
- `GET /users/1` → 200, a single object
- `GET /users/999` → **404**, body `{}`
- `POST /users` (JSON body) → **201**, the server echoes the body and adds `"id": 11` (nothing is really saved)
- `GET /users?id=3` → 200, a **list of one**, not an object

### User
| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| id | number | int | no |
| name | string | String | no |
| username | string | String | no |
| email | string | String | no |
| phone | string | String | no |
| website | string | String? | treated as optional |
| address | object | Address | no |
| company | object | record ({String name, String catchPhrase}) | no |

### Address
| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| street | string | String | no |
| suite | string | String | no |
| city | string | String | no |
| zipcode | string | String | no |
| geo | object (nested twice) | Geo | no |

### Geo
| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| lat | **string** ("-37.3159") | double (double.parse) | no |
| lng | **string** | double (double.parse) | no |

### Company
| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| name | string | String | no |
| catchPhrase | string | String | no |
| bs | string | not modelled | — |

## Level 5: timings (fill in after running on a device)
- Airplane mode → Offline view after: ___ s
- Wi-Fi without internet → Offline view after: ___ s (expected ≈ 10 s)
