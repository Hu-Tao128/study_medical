# API Documentation (Frontend Guide)

Base URL: `http://<backend-host>/api/v1`  
All endpoints return JSON. Most require JWT authentication via `Authorization: Bearer <token>` header.

---

## Authentication

### Token Format
All protected endpoints require JWT authentication. Include the token in the `Authorization` header:

```
Authorization: Bearer <your-jwt-token>
```

### Development Mode (Dev Login)
For development only (`app.dev-mode=true`), you can generate a test token:

**POST `/api/v1/auth/dev-login`** - Auth: No (dev only)
```javascript
const getDevToken = async () => {
  const response = await fetch('/api/v1/auth/dev-login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      userId: 'optional-custom-uuid',
      email: 'dev@example.com',
      name: 'Dev User'
    })
  });
  const data = await response.json();
  localStorage.setItem('jwt_token', data.accessToken);
  return data;
};
```

### Production Authentication
In production, the backend expects a valid JWT from your auth provider (Supabase/Firebase). The token must be:
- A valid JWT with proper signature
- Sent as: `Authorization: Bearer <token>`
- Contains claims: `sub` (user ID), `email`, `name` (optional)

**POST `/api/v1/auth/sync-session`** - Auth: Required
Syncs user session with backend, creates/updates user record:
```javascript
const syncSession = async () => {
  const token = localStorage.getItem('jwt_token');
  const response = await fetch('/api/v1/auth/sync-session', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${token}` }
  });
  if (!response.ok) throw new Error('Token invalido');
  return response.json();
};
```

---

## Endpoint Reference

### 1. Health & System Endpoints

#### GET `/` (Root Info)
- Auth: No
- Returns service info and endpoint map
- Success: 200

```javascript
fetch('/').then(r => r.json()) // Returns service metadata
```

#### GET `/health`
- Auth: No
- Check service status
- Success: 200 `{ "status": "UP", "service": "Study Medical Backend" }`

#### GET `/keep-alive`
- Auth: No
- Database connection check
- Success: 200 `{ "status": "OK", "database": "connected" }`

---

### 2. Search Endpoint

#### GET `/search`
- **Auth: Required (JWT Bearer)**
- Description: Search medical content across NIH/local sources with caching

**Query Parameters:**

| Param | Type | Required | Default | Validation |
|-------|------|----------|---------|------------|
| `q` | string | Yes | - | Non-empty, max 100 chars, trimmed |
| `source` | string | No | `all` | Must be `all`, `nih`, or `local` |
| `limit` | number | No | 5 | Max 20 |
| `page` | number | No | 1 | Min 1 |

**Success Response (200):** `SearchResponse` (contains results, pagination, sources)

**Error Status Codes:**

| Code | Reason | Response Body |
|------|--------|---------------|
| 400 | Invalid params | `{ "error": "El parámetro 'q' es requerido" }` / `{ "error": "Source inválido. Valores permitidos: [all, nih, local]" }` / max length error |
| 401 | Invalid/missing token | `{ "error": "Token invalido" }` |
| 429 | Rate limit exceeded | `{ "error": "Demasiadas solicitudes, intenta en unos segundos" }` |
| 500 | Server error | `{ "error": "Error interno del servidor" }` |

**Frontend Usage:**

```javascript
const searchMedical = async (query, source = 'all', limit = 5, page = 1) => {
  const token = localStorage.getItem('jwt_token');
  const url = new URL('/api/v1/search', window.location.origin);
  url.searchParams.set('q', query.trim());
  url.searchParams.set('source', source);
  url.searchParams.set('limit', limit);
  url.searchParams.set('page', page);

  const response = await fetch(url, {
    headers: { 'Authorization': `Bearer ${token}` }
  });

  if (response.status === 429) {
    alert('Too many requests, please wait');
    return;
  }
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error);
  }
  return response.json(); // Cached results will return instantly
};
```

---

### 3. Profile Endpoints

#### GET `/profile/me`
- Auth: Required
- Returns current user profile
- Success: 200 `ProfileResponseDto`
- Error: 401 (invalid token)

#### PATCH `/profile/me`
- Auth: Required
- Body: `{ displayName?, photoUrl?, preferredLanguage?, theme?, level?, semester?, career? }`
- Success: 200 updated profile
- Error: 401, 404 (user not found)

---

### 4. Topic Endpoints

#### GET `/topics`
- Auth: No
- Returns list of available study topics
- Success: 200 `[ { "id": "uuid", "name": "Topic Name" } ]`

---

### 5. Note Endpoints

All note endpoints require authentication and return 401 if token is invalid.

#### GET `/notes`
- Auth: Required
- Query Param: `topicId` (optional, UUID)
- Returns notes for current user, filtered by topic if provided
- Success: 200 `[ NoteResponseDto ]`

#### POST `/notes`
- Auth: Required
- Body: `{ title, contentMd, topicId?, tags?, aiSummary?, aiGenerated?, ... }`
- Success: 200 created note

#### GET `/notes/{id}`
- Auth: Required
- Get specific note by ID
- Success: 200 `NoteResponseDto`
- Error: 404 (not found), 403 (no access)

#### PUT `/notes/{id}`
- Auth: Required
- Body: Full update (all fields)
- Success: 200 updated note
- Error: 404, 403

#### PATCH `/notes/{id}`
- Auth: Required
- Body: Partial update (any fields optional)
- Success: 200 updated note
- Error: 404, 403

#### DELETE `/notes/{id}`
- Auth: Required
- Deletes note
- Success: 204 No Content
- Error: 404, 403

---

### 6. Quiz Endpoints

All quiz endpoints require authentication. Creation requires TEACHER or ADMIN role.

#### POST `/quizzes/ai-generate`
- Auth: Required (TEACHER/ADMIN role)
- Body: `{ title, topicId, questions?, visibility?, groupId? }`
- Generates quiz
- Success: 200 `QuizResponseDto`

#### POST `/quizzes/{quizId}/submit`
- Auth: Required
- Body: `{ userId, answers: [int] }`
- Returns quiz results with score
- Success: 200 `SubmitQuizResult`

#### GET `/quizzes/topic/{topicId}`
- Auth: Required
- Returns quizzes for a topic, filtered by visibility (PRIVATE/GROUP/PUBLIC)
- Success: 200 `[ QuizResponseDto ]`

#### GET `/quizzes/{id}`
- Auth: Required
- Get specific quiz by ID
- Success: 200 `QuizResponseDto`
- Error: 404, 403

#### PUT `/quizzes/{id}`
- Auth: Required (creator or ADMIN)
- Body: Full quiz update
- Success: 200 updated quiz
- Error: 404, 403

#### DELETE `/quizzes/{id}`
- Auth: Required (creator or ADMIN)
- Success: 204 No Content
- Error: 404, 403

---

### 7. Flashcard Endpoints

All flashcard endpoints require authentication. Creation requires TEACHER or ADMIN role.

#### POST `/flashcards`
- Auth: Required (TEACHER/ADMIN role)
- Body: `{ topicId, question, answer, difficulty?, visibility?, groupId?, tags? }`
- Creates flashcard
- Success: 200 `FlashcardResponseDto`

#### GET `/flashcards/topic/{topicId}`
- Auth: Required
- Returns flashcards for a topic, filtered by visibility
- Success: 200 `[ FlashcardResponseDto ]`

#### GET `/flashcards/{id}`
- Auth: Required
- Get specific flashcard
- Success: 200 `FlashcardResponseDto`
- Error: 404, 403

#### PUT `/flashcards/{id}`
- Auth: Required (creator or ADMIN)
- Body: Full update
- Success: 200 updated flashcard
- Error: 404, 403

#### DELETE `/flashcards/{id}`
- Auth: Required (creator or ADMIN)
- Success: 204 No Content
- Error: 404, 403

---

### 8. Clinical Case Endpoints

All clinical case endpoints require authentication. Creation requires TEACHER or ADMIN role.

#### POST `/cases`
- Auth: Required (TEACHER/ADMIN role)
- Body: `{ title, description, symptoms?, diagnosis, questions?, topicId, difficulty?, visibility?, groupId? }`
- Creates clinical case
- Success: 200 `ClinicalCaseResponseDto`

#### GET `/cases/topic/{topicId}`
- Auth: Required
- Returns clinical cases for a topic, filtered by visibility
- Success: 200 `[ ClinicalCaseResponseDto ]`

#### GET `/cases/{id}`
- Auth: Required
- Get specific clinical case
- Success: 200 `ClinicalCaseResponseDto`
- Error: 404, 403

#### PUT `/cases/{id}`
- Auth: Required (creator or ADMIN)
- Body: Full update
- Success: 200 updated case
- Error: 404, 403

#### DELETE `/cases/{id}`
- Auth: Required (creator or ADMIN)
- Success: 204 No Content
- Error: 404, 403

---

### 9. Study Session Endpoints

All study session endpoints require authentication.

#### POST `/study-sessions/start`
- Auth: Required
- Body: `{ topicId, mode?, limit? }`
- Starts a new study session with flashcards
- Success: 200 `{ sessionId, cards: [{ cardId, question, tags }] }`

#### POST `/study-sessions/submit`
- Auth: Required
- Body: `{ sessionId, topicId, attempts: [{ cardId, difficulty, correct, timeMs }] }`
- Submits study session results
- Success: 200 `SubmitStudySessionResult` with accuracy and stats

#### GET `/study-sessions`
- Auth: Required
- Query Param: `topicId` (optional)
- Returns user's study session history
- Success: 200 `[ StudySessionDto ]`

---

### 10. Progress Endpoints

All progress endpoints require authentication.

#### GET `/progress`
- Auth: Required
- Query Param: `topicId` (required, UUID)
- Returns study progress for a topic
- Success: 200 `{ accuracy, attempts, lastStudiedAt }`

#### GET `/progress/radar`
- Auth: Required
- Returns progress radar data across all topics
- Success: 200 `{ topics: [{ topicId, name, accuracy }] }`

---

### 11. Chat Endpoints

All chat endpoints require authentication and group access.

#### POST `/chat/{roomId}/messages`
- Auth: Required (must be group member)
- Body: `{ senderId, text, type? }`
- Sends a chat message to a study group room
- Success: 200 `ChatMessageBucketResponseDto`

#### GET `/chat/{roomId}/history`
- Auth: Required (must be group member)
- Returns chat history for a room
- Success: 200 `[ MessageDto ]`

---

## Common Status Codes

| Code | Meaning | Frontend Handling |
|------|---------|-------------------|
| 200 | Success | Parse response JSON |
| 201 | Created | Parse response JSON |
| 204 | No Content | No body to parse |
| 400 | Bad Request | Show validation error to user |
| 401 | Unauthorized | Token invalid/missing - redirect to login |
| 403 | Forbidden | Show "No access" message |
| 404 | Not Found | Show "Resource not found" |
| 429 | Rate Limited | Show retry message, implement backoff |
| 500 | Server Error | Show generic error, log to monitoring |

---

## Notes

- **Search results are cached in-memory**: repeated identical queries return instantly
- **JWT tokens are required for all endpoints except**: `/`, `/health`, `/keep-alive`, `/auth/dev-login` (dev only), `/auth/sync-session`, `/profile/**`, `/study-sessions/**`, `/progress/**`
- **Token extraction**: Backend extracts JWT from `Authorization: Bearer <token>` header OR from Spring Security's `@AuthenticationPrincipal Jwt`
- **Dev mode endpoints are disabled in production** (`app.dev-mode=false`)
- **Search cache uses adaptive TTL**: popular queries (diabetes, hypertension, etc.) cached for 60 min, others for 10 min
- **Role-based access**: TEACHER/ADMIN roles required for creating quizzes, flashcards, and clinical cases
- **Visibility system**: Resources can be PRIVATE (only creator), GROUP (group members), or PUBLIC (all authenticated users)
