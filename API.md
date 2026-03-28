# Study Medical Backend API (v1)

## Base URL
- `http://<host>:<port>/api/v1`

## Headers
- Endpoints protegidos:
  - `Authorization: Bearer <firebase_id_token>`
- Requests JSON:
  - `Content-Type: application/json`

## Flujo de autenticacion recomendado
1. Login en Firebase.
2. Obtener ID Token.
3. Llamar `POST /auth/sync-session`.
4. Reutilizar el mismo token en endpoints protegidos.

## Endpoints

### Auth y perfil
- `POST /auth/sync-session` (auth, body vacio)
- `GET /profile/me` (auth)
- `PATCH /profile/me` (auth)
  - Opcionales: `displayName`, `photoUrl`, `preferredLanguage`, `theme`, `level`, `semester`, `career`

### Study loop
- `POST /study-sessions/start` (auth)
  - Requerido: `topicId`
  - Opcionales: `mode`, `limit`
- `POST /study-sessions/submit` (auth)
  - Requeridos: `sessionId`, `topicId`
  - Opcional: `attempts[]`
- `GET /study-sessions?topicId=<uuid-opcional>` (auth)
- `GET /progress?topicId=<uuid>` (auth)
- `GET /progress/radar` (auth)

### Notes
- `POST /notes` (auth)
  - Requeridos: `userId`, `title`, `contentMd`, `topicId`
  - Opcionales: `aiSummary`, `aiEmbeddingsId`, `aiGenerated`, `aiModel`, `aiSource`, `tags`, `isFavorite`, `isArchived`
- `GET /notes/{id}` (auth)
- `GET /notes?topicId=<uuid-opcional>` (auth)
- `GET /notes/user/{userId}` (auth)
- `PUT /notes/{id}` (auth)
- `PATCH /notes/{id}` (auth)
  - Todo opcional: `title`, `contentMd`, `topicId`, `tags`, `isFavorite`, `isArchived`
- `DELETE /notes/{id}` (auth)

### Flashcards
- `POST /flashcards` (auth)
  - Requeridos: `topicId`, `question`, `answer`
  - Opcionales: `difficulty`, `visibility`, `groupId`, `tags`, `aiGenerated`, `aiModel`, `aiSource`, `aiEmbeddingsId`
- `GET /flashcards/topic/{topicId}` (auth)
- `GET /flashcards/{id}` (auth)
- `PUT /flashcards/{id}` (auth)
- `DELETE /flashcards/{id}` (auth)

### Quizzes
- `POST /quizzes/ai-generate` (auth)
  - Requeridos: `title`, `topicId`
  - Opcionales: `questions[]`, `visibility`, `groupId`, `aiGenerated`, `aiModel`, `aiSource`, `aiEmbeddingsId`
- `GET /quizzes/topic/{topicId}` (auth)
- `GET /quizzes/{id}` (auth)
- `PUT /quizzes/{id}` (auth)
- `DELETE /quizzes/{id}` (auth)
- `POST /quizzes/{quizId}/submit` (auth)
  - Requerido: `userId`
  - Opcional: `answers[]`

### Clinical Cases
- `POST /cases` (auth)
  - Requeridos: `title`, `description`, `diagnosis`, `topicId`
  - Opcionales: `symptoms`, `questions`, `difficulty`, `visibility`, `groupId`, `aiGenerated`, `aiModel`, `aiSource`, `aiEmbeddingsId`
- `GET /cases/topic/{topicId}` (auth)
- `GET /cases/{id}` (auth)
- `PUT /cases/{id}` (auth)
- `DELETE /cases/{id}` (auth)

### Chat
- `POST /chat/{roomId}/messages` (auth)
  - Requeridos: `senderId`, `text`
  - Opcional: `type`
- `GET /chat/{roomId}/history` (auth)

### Health
- `GET /api/v1/health` (publico)

## Reglas de visibilidad
- `PRIVATE`: owner
- `GROUP`: miembros del grupo
- `PUBLIC`: autenticados

## HTTP status frecuentes
- `200`, `204`, `400`, `401`, `403`, `404`, `500`

`ENDPOINTS_BACKEND.md` sigue siendo la referencia operativa detallada.
