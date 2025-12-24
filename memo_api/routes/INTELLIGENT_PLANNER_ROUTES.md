# Intelligent Planner Routes Integration

## Routes to Add to `routes/api.php`

Add these routes inside the `Route::middleware('auth:sanctum')->group(function () {` block:

```php
// Intelligent Planner - Subject Selection Flow
Route::prefix('v1')->group(function () {
    // Get academic subjects (filtered by user profile)
    Route::get('/subjects', [App\Http\Controllers\Api\V1\SubjectController::class, 'index']);

    // Planner Subjects Management
    Route::prefix('planner/subjects')->group(function () {
        // Get user's planner subjects
        Route::get('/', [App\Http\Controllers\Api\V1\PlannerSubjectsController::class, 'index']);

        // Batch create subjects (Intelligent Planner core feature)
        Route::post('/batch', [App\Http\Controllers\Api\V1\PlannerSubjectsController::class, 'batchCreate']);

        // Individual subject operations
        Route::get('/{id}', [App\Http\Controllers\Api\V1\PlannerSubjectsController::class, 'show']);
        Route::put('/{id}', [App\Http\Controllers\Api\V1\PlannerSubjectsController::class, 'update']);
        Route::delete('/{id}', [App\Http\Controllers\Api\V1\PlannerSubjectsController::class, 'destroy']);
    });
});
```

## Existing Controllers

### ✅ App\Http\Controllers\Api\V1\SubjectController
**Location**: `app/Http/Controllers/Api/V1/SubjectController.php`

**Features**:
- Filters subjects by authenticated user's academic profile
- Returns stream-specific subjects + common subjects
- Automatically uses `academic_year_id` and `academic_stream_id` from user profile
- Sorted by coefficient (importance)

**Endpoint**: `GET /api/v1/subjects`

**Sample Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name_ar": "الرياضيات",
      "name_fr": "Mathématiques",
      "coefficient": 7,
      "color": "#4CAF50",
      "icon": "📐",
      "academic_year_id": 12,
      "academic_stream_id": 1
    },
    {
      "id": 10,
      "name_ar": "اللغة العربية",
      "coefficient": 2,
      "academic_year_id": 12,
      "academic_stream_id": null
    }
  ]
}
```

### ✅ App\Http\Controllers\Api\V1\PlannerSubjectsController
**Location**: `app/Http/Controllers/Api/V1/PlannerSubjectsController.php`

**Features**:
- Batch creation with atomic transactions
- Duplicate prevention
- Validation of business rules
- CRUD operations for planner subjects

**Endpoints**:

1. **Batch Create** - `POST /api/v1/planner/subjects/batch`
   ```json
   {
     "subjects": [
       {
         "subject_id": 1,
         "difficulty_level": 5,
         "priority": "critical",
         "progress_percentage": 0
       },
       {
         "subject_id": 2,
         "difficulty_level": 4,
         "priority": "high",
         "progress_percentage": 0
       }
     ]
   }
   ```

   Response (201):
   ```json
   {
     "success": true,
     "message": "2 مواد تم إضافتها بنجاح",
     "data": {
       "created_count": 2,
       "subjects": [...]
     }
   }
   ```

2. **Get User's Planner Subjects** - `GET /api/v1/planner/subjects`

3. **Get Single Subject** - `GET /api/v1/planner/subjects/{id}`

4. **Update Subject** - `PUT /api/v1/planner/subjects/{id}`

5. **Delete Subject** - `DELETE /api/v1/planner/subjects/{id}`

## Database Requirements

Ensure the `planner_subjects` table exists with the following structure:

```php
Schema::create('planner_subjects', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('subject_id')->constrained()->onDelete('cascade');
    $table->integer('difficulty_level')->default(3); // 1-5
    $table->enum('priority', ['low', 'medium', 'high', 'critical'])->default('medium');
    $table->integer('progress_percentage')->default(0); // 0-100
    $table->boolean('is_active')->default(true);
    $table->timestamps();

    // Prevent duplicates
    $table->unique(['user_id', 'subject_id']);
});
```

## Testing the Endpoints

### 1. Test Subject Fetching
```bash
curl -X GET "http://localhost:8000/api/v1/subjects" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

### 2. Test Batch Creation
```bash
curl -X POST "http://localhost:8000/api/v1/planner/subjects/batch" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "subjects": [
      {
        "subject_id": 1,
        "difficulty_level": 5,
        "priority": "critical",
        "progress_percentage": 0
      },
      {
        "subject_id": 2,
        "difficulty_level": 4,
        "priority": "high",
        "progress_percentage": 0
      }
    ]
  }'
```

### 3. Test Get Planner Subjects
```bash
curl -X GET "http://localhost:8000/api/v1/planner/subjects" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

## Business Rules Enforced

- **BR-IP-001**: User must have complete academic profile (year + stream)
- **BR-IP-005**: Minimum 1 subject required in batch
- **BR-IP-006**: Maximum 20 subjects allowed in batch
- **BR-IP-007**: Duplicate prevention (both in request and database)
- **BR-IP-008**: Batch atomicity (all-or-nothing transaction)

## Integration Complete ✅

The backend is fully implemented and ready to integrate with the Flutter app!
