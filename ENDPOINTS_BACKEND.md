# Endpoints del Backend (Uso desde Frontend)

Este documento describe todos los endpoints del backend, los headers requeridos y el flujo recomendado de autenticacion para Flutter/Web/Mobile.

## 1) Autenticacion y sesion

### Flujo recomendado (Firebase -> Backend)
1. El frontend autentica con Firebase (email/password, Google, Apple, etc.).
2. Obtiene el **Firebase ID Token**.
3. Llama a `/api/v1/auth/sync-session` enviando el token.
4. El backend crea o actualiza el usuario en `users` y devuelve el perfil.

**Header obligatorio en todas las llamadas protegidas:**
```
Authorization: Bearer <firebase_id_token>
```

### POST /api/v1/auth/sync-session
Sincroniza el usuario autenticado en Supabase/Postgres.

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

**Response 200**
```json
{
  "id": "uuid",
  "authId": "uuid",
  "email": "user@example.com",
  "displayName": "Nombre",
  "role": "STUDENT",
  "lastLoginAt": "2026-03-26T00:25:40"
}
```

---

## 2) Perfil del usuario

### GET /api/v1/profile/me
Devuelve el perfil del usuario autenticado.

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

### PATCH /api/v1/profile/me
Actualiza campos editables del perfil.

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

**Body (ejemplo)**
```json
{
  "displayName": "Ana",
  "photoUrl": "https://...",
  "preferredLanguage": "es",
  "theme": "system",
  "level": "pregrado",
  "semester": 3,
  "career": "Medicina"
}
```

---

## 3) Flashcards

### POST /api/v1/flashcards
Crear flashcard.

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

**Reglas de acceso**
- `TEACHER` o `ADMIN` para crear.
- Si `visibility = GROUP`, debe ser **teacher** en ese grupo (`groupId`).

**Body**
```json
{
  "topicId": "uuid",
  "question": "...",
  "answer": "...",
  "difficulty": "EASY|MEDIUM|HARD",
  "visibility": "PRIVATE|GROUP|PUBLIC",
  "groupId": "uuid",
  "tags": ["anatomy"],
  "aiGenerated": false,
  "aiModel": "gpt-4",
  "aiSource": "Harrison capítulo 12",
  "aiEmbeddingsId": "vector_id"
}
```

### GET /api/v1/flashcards/topic/{topicId}
Devuelve flashcards visibles para el usuario.

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

**Visibilidad**
- `PRIVATE`: solo owner
- `GROUP`: miembros del grupo
- `PUBLIC`: todos autenticados

---

## 4) Quizzes

### POST /api/v1/quizzes/ai-generate
Crear quiz (incluye metadatos AI opcionales).

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

**Reglas de acceso**
- `TEACHER` o `ADMIN` para crear.
- Si `visibility = GROUP`, debe ser **teacher** en el grupo.

**Body**
```json
{
  "title": "Cardiologia basica",
  "topicId": "uuid",
  "questions": [
    {
      "question": "...",
      "options": ["A", "B", "C"],
      "correctAnswer": 1,
      "explanation": "...",
      "aiGenerated": true
    }
  ],
  "visibility": "PRIVATE|GROUP|PUBLIC",
  "groupId": "uuid",
  "aiGenerated": true,
  "aiModel": "gpt-4",
  "aiSource": "Harrison cap 12",
  "aiEmbeddingsId": "vector_id"
}
```

### GET /api/v1/quizzes/topic/{topicId}
Devuelve quizzes visibles para el usuario.

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

### POST /api/v1/quizzes/{quizId}/submit
Enviar respuestas. Actualiza `user_progress`.

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

**Body**
```json
{
  "userId": "uuid",
  "answers": [0, 1, 2]
}
```

**Reglas de acceso**
- Solo owner en `PRIVATE`
- Miembro en `GROUP`
- Autenticado en `PUBLIC`

---

## 5) Clinical Cases

### POST /api/v1/cases
Crear caso clinico.

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

**Reglas de acceso**
- `TEACHER` o `ADMIN` para crear.
- Si `visibility = GROUP`, debe ser **teacher** en el grupo.

**Body**
```json
{
  "title": "Caso: Dolor toracico",
  "description": "...",
  "symptoms": ["dolor", "disnea"],
  "diagnosis": "...",
  "questions": [
    {
      "question": "...",
      "options": ["A", "B"],
      "correctAnswer": 0,
      "explanation": "..."
    }
  ],
  "topicId": "uuid",
  "difficulty": "MEDIUM",
  "visibility": "PRIVATE|GROUP|PUBLIC",
  "groupId": "uuid",
  "aiGenerated": false,
  "aiModel": "gpt-4",
  "aiSource": "Harrison cap 12",
  "aiEmbeddingsId": "vector_id"
}
```

### GET /api/v1/cases/topic/{topicId}
Devuelve casos visibles.

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

---

## 6) Notes

### POST /api/v1/notes
Crear nota personal.

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

**Body**
```json
{
  "userId": "uuid",
  "title": "Apuntes",
  "contentMd": "# ...",
  "topicId": "uuid",
  "aiSummary": null,
  "aiEmbeddingsId": null,
  "aiGenerated": false,
  "aiModel": "gpt-4",
  "aiSource": "Harrison cap 12"
}
```

### PUT /api/v1/notes/{id}
Actualizar nota.

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

### GET /api/v1/notes/user/{userId}
Listar notas por usuario.

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

---

## 7) Chat

### POST /api/v1/chat/{roomId}/messages
Enviar mensaje al grupo.

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

**Reglas**
- `roomId` == `groupId`
- Debe ser miembro del grupo

**Body**
```json
{
  "senderId": "uuid",
  "text": "mensaje",
  "type": "TEXT|IMAGE|FILE"
}
```

### GET /api/v1/chat/{roomId}/history
Devuelve historial del chat.

**Headers**
```
Authorization: Bearer <firebase_id_token>
```

**Reglas**
- Debe ser miembro del grupo

---

## 8) Health

### GET /api/v1/health
Endpoint publico para liveness.

---

## Notas de implementacion frontend

1. Guardar el `firebase_id_token` en memoria segura (no localStorage en web).
2. Renovar token cuando Firebase lo rote.
3. Siempre reenviar `Authorization: Bearer <token>` en cada request.
4. Para endpoints con `GROUP`, enviar `groupId` y validar que el usuario sea miembro/teacher antes de mostrar opciones.
5. Para contenidos `PRIVATE`, filtrar en UI por `createdBy == currentUserId` si necesitas ocultar localmente.
