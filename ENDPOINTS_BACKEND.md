# ENDPOINTS_BACKEND

Guia operativa para integrar frontend con backend (v1).

## Base URL
- `http://<host>:<port>/api/v1`

## Headers
- Protegidos:
  - `Authorization: Bearer <firebase_id_token>`
- Con body JSON:
  - `Content-Type: application/json`

## Auth y perfil

### `POST /auth/sync-session`
- Auth: requerido
- Body: vacio
- Respuesta: perfil sincronizado

### `GET /profile/me`
- Auth: requerido
- Body: no

### `PATCH /profile/me`
- Auth: requerido
- Body:
  - Opcionales: `displayName`, `photoUrl`, `preferredLanguage`, `theme`, `level`, `semester`, `career`

---

## Topics (fuente unica para frontend)

Frontend NO debe definir topics hardcodeados.

### `GET /topics`
- Auth: requerido
- Devuelve lista completa de topics.

### `GET /topics/{id}`
- Auth: requerido

### `POST /topics`
- Auth: requerido
- Rol: `ADMIN`
- Body:
  - Requerido: `name`
  - Opcionales: `slug`, `description`, `parentId`

### `PUT /topics/{id}`
- Auth: requerido
- Rol: `ADMIN`
- Body:
  - Requerido: `name`
  - Opcionales: `slug`, `description`, `parentId`

### `DELETE /topics/{id}`
- Auth: requerido
- Rol: `ADMIN`

Modelo de respuesta topic:
```json
{
  "id": "uuid",
  "name": "Cardiologia",
  "slug": "cardiologia",
  "description": "...",
  "parentId": null,
  "createdAt": "2026-03-28T12:00:00"
}
```

---

## Study loop (core)

### `POST /study-sessions/start`
- Auth: requerido
- Body:
  - Requerido: `topicId`
  - Opcionales: `mode` (default `FLASHCARDS`), `limit` (default backend 20, max 100)

Ejemplo:
```json
{
  "topicId": "f6af8f78-6fcd-4e54-a4fb-4ec2b36a6c57",
  "mode": "FLASHCARDS",
  "limit": 20
}
```

### `POST /study-sessions/submit`
- Auth: requerido
- Body:
  - Requeridos: `sessionId`, `topicId`
  - Opcional: `attempts` (si no se envia, se toma vacio)
  - Campos por intento:
    - Requerido: `cardId`
    - Opcionales: `difficulty`, `correct`, `timeMs`

Ejemplo:
```json
{
  "sessionId": "42af9f4a-155d-413a-a77b-6ad9a4143e7d",
  "topicId": "f6af8f78-6fcd-4e54-a4fb-4ec2b36a6c57",
  "attempts": [
    { "cardId": "67f3c9...", "difficulty": 3, "correct": true, "timeMs": 12000 }
  ]
}
```

### `GET /study-sessions?topicId=<uuid-opcional>`
- Auth: requerido
- Query:
  - Opcional: `topicId`

### `GET /progress?topicId=<uuid>`
- Auth: requerido
- Query:
  - Requerido: `topicId`

### `GET /progress/radar`
- Auth: requerido
- Body/query: no

---

## Notes

### `POST /notes`
- Auth: requerido
- Body:
  - Requeridos: `userId`, `title`, `contentMd`, `topicId`
  - Opcionales: `aiSummary`, `aiEmbeddingsId`, `aiGenerated`, `aiModel`, `aiSource`, `tags`, `isFavorite`, `isArchived`

### `GET /notes/{id}`
- Auth: requerido

### `GET /notes?topicId=<uuid-opcional>`
- Auth: requerido
- Query opcional: `topicId`

### `GET /notes/user/{userId}`
- Auth: requerido

### `PUT /notes/{id}`
- Auth: requerido
- Body: mismo contrato que `POST /notes`

### `PATCH /notes/{id}`
- Auth: requerido
- Body (todo opcional): `title`, `contentMd`, `topicId`, `tags`, `isFavorite`, `isArchived`

### `DELETE /notes/{id}`
- Auth: requerido

---

## Flashcards

### `POST /flashcards`
- Auth: requerido
- Body:
  - Requeridos: `topicId`, `question`, `answer`
  - Opcionales: `difficulty`, `visibility`, `groupId`, `tags`, `aiGenerated`, `aiModel`, `aiSource`, `aiEmbeddingsId`

### `GET /flashcards/topic/{topicId}`
- Auth: requerido

### `GET /flashcards/{id}`
- Auth: requerido

### `PUT /flashcards/{id}`
- Auth: requerido
- Body: mismo contrato que `POST /flashcards`

### `DELETE /flashcards/{id}`
- Auth: requerido

---

## Quizzes

### `POST /quizzes/ai-generate`
- Auth: requerido
- Body:
  - Requeridos: `title`, `topicId`
  - Opcionales: `questions[]`, `visibility`, `groupId`, `aiGenerated`, `aiModel`, `aiSource`, `aiEmbeddingsId`
  - `questions[]` item:
    - Requeridos: `question`, `correctAnswer`
    - Opcionales: `options`, `explanation`, `aiGenerated`

### `GET /quizzes/topic/{topicId}`
- Auth: requerido

### `GET /quizzes/{id}`
- Auth: requerido

### `PUT /quizzes/{id}`
- Auth: requerido
- Body: mismo contrato que `POST /quizzes/ai-generate`

### `DELETE /quizzes/{id}`
- Auth: requerido

### `POST /quizzes/{quizId}/submit`
- Auth: requerido
- Body:
  - Requerido: `userId`
  - Opcional: `answers` (array de enteros)

Nota de seguridad: por ahora `userId` se valida contra el usuario autenticado (o rol admin/teacher). En una fase posterior se puede eliminar del body y derivarlo 100% del JWT para endurecer contrato.

---

## Clinical Cases

### `POST /cases`
- Auth: requerido
- Body:
  - Requeridos: `title`, `description`, `diagnosis`, `topicId`
  - Opcionales: `symptoms`, `questions`, `difficulty`, `visibility`, `groupId`, `aiGenerated`, `aiModel`, `aiSource`, `aiEmbeddingsId`

### `GET /cases/topic/{topicId}`
- Auth: requerido

### `GET /cases/{id}`
- Auth: requerido

### `PUT /cases/{id}`
- Auth: requerido
- Body: mismo contrato que `POST /cases`

### `DELETE /cases/{id}`
- Auth: requerido

---

## Chat

### `POST /chat/{roomId}/messages`
- Auth: requerido
- Body:
  - Requeridos: `senderId`, `text`
  - Opcional: `type` (`TEXT`, `IMAGE`, `FILE`)

Nota de seguridad: `senderId` tambien se valida contra el usuario autenticado (o admin). En una fase posterior se recomienda derivar siempre del JWT.

### `GET /chat/{roomId}/history`
- Auth: requerido

---

## Health
- `GET /api/v1/health` (publico)

## Visibilidad y permisos
- `PRIVATE`: owner
- `GROUP`: miembros del grupo
- `PUBLIC`: autenticados
- Crear contenido `GROUP`: teacher/admin con permisos en grupo

## HTTP status esperados
- `200`, `204`, `400`, `401`, `403`, `404`, `500`
