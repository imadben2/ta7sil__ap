<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Quiz;
use App\Models\QuizQuestion;
use App\Models\Subject;
use App\Models\ContentChapter;
use App\Models\AcademicPhase;
use App\Models\AcademicYear;
use App\Models\AcademicStream;
use App\Services\QuizService;
use App\Imports\QuestionsImport;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Facades\Excel;
use Illuminate\Support\Facades\Storage;
use Yajra\DataTables\Facades\DataTables;

class QuizController extends Controller
{
    protected QuizService $quizService;

    public function __construct(QuizService $quizService)
    {
        $this->quizService = $quizService;
    }

    /**
     * Display quiz overview dashboard
     */
    public function index(Request $request)
    {
        if ($request->ajax()) {
            return $this->getDataTable($request);
        }

        $subjects = Subject::all();

        return view('admin.quizzes.index', compact('subjects'));
    }

    /**
     * Get DataTables data for quizzes
     */
    private function getDataTable(Request $request)
    {
        $query = Quiz::with(['subject', 'chapter', 'creator']);

        // Filters
        if ($request->filled('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        if ($request->filled('difficulty')) {
            $query->where('difficulty_level', $request->difficulty);
        }

        if ($request->filled('type')) {
            $query->where('quiz_type', $request->type);
        }

        if ($request->filled('status')) {
            if ($request->status === 'published') {
                $query->where('is_published', true);
            } elseif ($request->status === 'draft') {
                $query->where('is_published', false);
            }
        }

        return DataTables::of($query)
            ->addColumn('title', function($quiz) {
                $html = '<div class="font-semibold text-gray-900">' . e($quiz->title_ar) . '</div>';
                if ($quiz->chapter) {
                    $html .= '<div class="text-xs text-gray-500 mt-1">' . e($quiz->chapter->title_ar) . '</div>';
                }
                return $html;
            })
            ->addColumn('subject', function($quiz) {
                return $quiz->subject
                    ? '<span class="px-2 py-1 bg-blue-100 text-blue-700 rounded-full text-xs font-semibold">' . e($quiz->subject->name_ar) . '</span>'
                    : '-';
            })
            ->addColumn('type', function($quiz) {
                $types = [
                    'practice' => ['text' => 'تدريب', 'color' => 'green'],
                    'timed' => ['text' => 'موقوت', 'color' => 'yellow'],
                    'exam' => ['text' => 'امتحان', 'color' => 'red'],
                ];
                $type = $types[$quiz->quiz_type] ?? ['text' => $quiz->quiz_type, 'color' => 'gray'];
                return '<span class="px-2 py-1 bg-' . $type['color'] . '-100 text-' . $type['color'] . '-700 rounded-full text-xs font-semibold">' . $type['text'] . '</span>';
            })
            ->addColumn('difficulty', function($quiz) {
                $badges = [
                    'easy' => '<span class="px-2 py-1 bg-green-100 text-green-700 rounded-full text-xs font-semibold">سهل</span>',
                    'medium' => '<span class="px-2 py-1 bg-yellow-100 text-yellow-700 rounded-full text-xs font-semibold">متوسط</span>',
                    'hard' => '<span class="px-2 py-1 bg-red-100 text-red-700 rounded-full text-xs font-semibold">صعب</span>',
                ];
                return $badges[$quiz->difficulty_level] ?? '-';
            })
            ->addColumn('questions', function($quiz) {
                return '<div class="text-center"><span class="font-bold text-blue-600">' . $quiz->questions_count . '</span> <span class="text-xs text-gray-500">سؤال</span></div>';
            })
            ->addColumn('stats', function($quiz) {
                return '
                    <div class="text-xs text-gray-600">
                        <div><i class="fas fa-users text-blue-500"></i> ' . number_format($quiz->total_attempts ?? 0) . ' محاولة</div>
                        <div><i class="fas fa-chart-line text-green-500"></i> ' . round($quiz->average_score ?? 0, 1) . '% متوسط</div>
                    </div>
                ';
            })
            ->addColumn('status', function($quiz) {
                if ($quiz->is_published) {
                    return '<span class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-bold">منشور</span>';
                } else {
                    return '<span class="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-xs font-bold">مسودة</span>';
                }
            })
            ->addColumn('actions', function($quiz) {
                return '
                    <div class="flex gap-2">
                        <a href="' . route('admin.quizzes.show', $quiz->id) . '"
                           class="px-3 py-1 bg-blue-100 hover:bg-blue-200 text-blue-700 rounded text-sm font-semibold transition">
                            <i class="fas fa-eye"></i> عرض
                        </a>
                        <a href="' . route('admin.quizzes.edit', $quiz->id) . '"
                           class="px-3 py-1 bg-yellow-100 hover:bg-yellow-200 text-yellow-700 rounded text-sm font-semibold transition">
                            <i class="fas fa-edit"></i> تعديل
                        </a>
                    </div>
                ';
            })
            ->rawColumns(['title', 'subject', 'type', 'difficulty', 'questions', 'stats', 'status', 'actions'])
            ->make(true);
    }

    /**
     * Show create quiz form
     */
    public function create()
    {
        $phases = AcademicPhase::orderBy('order')->get();

        return view('admin.quizzes.create', compact('phases'));
    }

    /**
     * Store new quiz
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'subject_id' => 'nullable|exists:subjects,id',
            'chapter_id' => 'nullable|exists:content_chapters,id',
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'quiz_type' => 'required|in:practice,timed,exam',
            'time_limit_minutes' => 'nullable|integer|min:1',
            'passing_score' => 'required|integer|min:0|max:100',
            'difficulty_level' => 'required|in:easy,medium,hard',
            'estimated_duration_minutes' => 'nullable|integer|min:1',
            'shuffle_questions' => 'boolean',
            'shuffle_answers' => 'boolean',
            'show_correct_answers' => 'boolean',
            'allow_review' => 'boolean',
            'tags' => 'nullable|array',
            'is_premium' => 'boolean',
        ]);

        try {
            $quiz = $this->quizService->createQuiz($validated, auth()->user());

            return redirect()->route('admin.quizzes.show', $quiz->id)
                ->with('success', 'تم إنشاء الكويز بنجاح');

        } catch (\Exception $e) {
            return back()->withInput()
                ->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Show quiz details
     */
    public function show($id)
    {
        $quiz = Quiz::with(['subject', 'chapter', 'questions', 'creator', 'attempts'])
            ->findOrFail($id);

        $stats = $this->quizService->getQuizStatistics($quiz);

        return view('admin.quizzes.show', compact('quiz', 'stats'));
    }

    /**
     * Show edit quiz form
     */
    public function edit($id)
    {
        $quiz = Quiz::with(['questions', 'subject.academicYear.academicPhase', 'subject.academicStream'])->findOrFail($id);
        $phases = AcademicPhase::orderBy('order')->get();

        return view('admin.quizzes.edit', compact('quiz', 'phases'));
    }

    /**
     * Update quiz
     */
    public function update(Request $request, $id)
    {
        $quiz = Quiz::findOrFail($id);

        $validated = $request->validate([
            'subject_id' => 'nullable|exists:subjects,id',
            'chapter_id' => 'nullable|exists:content_chapters,id',
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'quiz_type' => 'required|in:practice,timed,exam',
            'time_limit_minutes' => 'nullable|integer|min:1',
            'passing_score' => 'required|integer|min:0|max:100',
            'difficulty_level' => 'required|in:easy,medium,hard',
            'estimated_duration_minutes' => 'nullable|integer|min:1',
            'shuffle_questions' => 'boolean',
            'shuffle_answers' => 'boolean',
            'show_correct_answers' => 'boolean',
            'allow_review' => 'boolean',
            'tags' => 'nullable|array',
            'is_premium' => 'boolean',
        ]);

        try {
            $this->quizService->updateQuiz($quiz, $validated);

            return redirect()->route('admin.quizzes.show', $quiz->id)
                ->with('success', 'تم تحديث الكويز بنجاح');

        } catch (\Exception $e) {
            return back()->withInput()
                ->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Delete quiz
     */
    public function destroy($id)
    {
        $quiz = Quiz::findOrFail($id);

        try {
            $this->quizService->deleteQuiz($quiz);

            return redirect()->route('admin.quizzes.index')
                ->with('success', 'تم حذف الكويز بنجاح');

        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Publish quiz
     */
    public function publish($id)
    {
        $quiz = Quiz::findOrFail($id);

        try {
            $this->quizService->publishQuiz($quiz);

            return back()->with('success', 'تم نشر الكويز بنجاح');

        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Unpublish quiz
     */
    public function unpublish($id)
    {
        $quiz = Quiz::findOrFail($id);

        try {
            $this->quizService->unpublishQuiz($quiz);

            return back()->with('success', 'تم إلغاء نشر الكويز بنجاح');

        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Duplicate quiz
     */
    public function duplicate($id)
    {
        $quiz = Quiz::findOrFail($id);

        try {
            $newQuiz = $this->quizService->duplicateQuiz($quiz, auth()->user());

            return redirect()->route('admin.quizzes.edit', $newQuiz->id)
                ->with('success', 'تم نسخ الكويز بنجاح');

        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Analytics dashboard
     */
    public function analytics(Request $request)
    {
        $startDate = $request->input('start_date', now()->subDays(30)->format('Y-m-d'));
        $endDate = $request->input('end_date', now()->format('Y-m-d'));

        // Overall stats
        $stats = [
            'total_quizzes' => Quiz::published()->count(),
            'total_attempts_month' => DB::table('quiz_attempts')
                ->whereBetween('started_at', [$startDate, $endDate])
                ->count(),
            'average_score' => round(
                DB::table('quiz_attempts')
                    ->whereBetween('started_at', [$startDate, $endDate])
                    ->where('status', 'completed')
                    ->avg('score_percentage'),
                1
            ),
            'pass_rate' => DB::table('quiz_attempts')
                ->whereBetween('started_at', [$startDate, $endDate])
                ->where('status', 'completed')
                ->where('passed', true)
                ->count() / max(1, DB::table('quiz_attempts')
                    ->whereBetween('started_at', [$startDate, $endDate])
                    ->where('status', 'completed')
                    ->count()) * 100,
        ];

        // Most popular quizzes
        $popularQuizzes = Quiz::with('subject')
            ->orderBy('total_attempts', 'desc')
            ->take(10)
            ->get();

        // Most difficult quizzes (lowest average score)
        $difficultQuizzes = Quiz::with('subject')
            ->where('average_score', '>', 0)
            ->orderBy('average_score', 'asc')
            ->take(10)
            ->get();

        // Never attempted quizzes
        $neverAttempted = Quiz::published()
            ->where('total_attempts', 0)
            ->with('subject')
            ->get();

        // Performance by subject
        $performanceBySubject = DB::table('quizzes')
            ->join('subjects', 'quizzes.subject_id', '=', 'subjects.id')
            ->select(
                'subjects.name_ar as name',
                DB::raw('COUNT(DISTINCT quizzes.id) as quiz_count'),
                DB::raw('COALESCE(AVG(quizzes.average_score), 0) as avg_score'),
                DB::raw('SUM(quizzes.total_attempts) as total_attempts')
            )
            ->where('quizzes.is_published', true)
            ->groupBy('subjects.id', 'subjects.name_ar')
            ->get();

        return view('admin.quizzes.analytics', compact(
            'stats',
            'popularQuizzes',
            'difficultQuizzes',
            'neverAttempted',
            'performanceBySubject',
            'startDate',
            'endDate'
        ));
    }

    /**
     * Question management page
     */
    public function questions($id)
    {
        $quiz = Quiz::with('questions')->findOrFail($id);

        return view('admin.quizzes.questions', compact('quiz'));
    }

    /**
     * Store new question
     */
    public function storeQuestion(Request $request, $id)
    {
        $quiz = Quiz::findOrFail($id);

        $validated = $request->validate([
            'question_type' => 'required|in:single_choice,multiple_choice,true_false,matching,ordering,fill_blank,short_answer,numeric',
            'question_text_ar' => 'required|string',
            'question_image_url' => 'nullable|url',
            'options' => 'nullable|array',
            'correct_answer' => 'required|array',
            'points' => 'required|integer|min:1',
            'explanation_ar' => 'nullable|string',
            'difficulty' => 'nullable|in:easy,medium,hard',
            'tags' => 'nullable',
        ]);

        try {
            // Map form question types to database enum values
            $questionTypeMap = [
                'single_choice' => 'mcq_single',
                'multiple_choice' => 'mcq_multiple',
                'true_false' => 'true_false',
                'matching' => 'matching',
                'ordering' => 'sequence',
                'fill_blank' => 'fill_blank',
                'short_answer' => 'short_answer',
                'numeric' => 'short_answer',
            ];

            $dbQuestionType = $questionTypeMap[$validated['question_type']] ?? $validated['question_type'];
            $validated['question_type'] = $dbQuestionType;

            // Process correct_answer based on question type
            $correctAnswer = $validated['correct_answer'];

            switch ($dbQuestionType) {
                case 'true_false':
                    // Convert string "true"/"false" to boolean
                    if (isset($correctAnswer['answer'])) {
                        $answer = $correctAnswer['answer'];
                        if ($answer === 'true' || $answer === '1' || $answer === 1) {
                            $correctAnswer = ['answer' => true];
                        } elseif ($answer === 'false' || $answer === '0' || $answer === 0) {
                            $correctAnswer = ['answer' => false];
                        }
                    }
                    break;

                case 'mcq_single':
                    // Ensure answer is an integer
                    if (isset($correctAnswer['answer'])) {
                        $correctAnswer = ['answer' => (int)$correctAnswer['answer']];
                    }
                    break;

                case 'mcq_multiple':
                    // Ensure answers is an array of integers
                    if (isset($correctAnswer['answers'])) {
                        $correctAnswer = ['answers' => array_map('intval', (array)$correctAnswer['answers'])];
                    }
                    break;

                case 'sequence':
                    // Parse order if it's a JSON string
                    if (isset($correctAnswer['order']) && is_string($correctAnswer['order'])) {
                        $order = json_decode($correctAnswer['order'], true);
                        $correctAnswer = ['order' => $order ?? []];
                    }
                    break;

                case 'matching':
                    // Keep pairs as string
                    $correctAnswer = ['pairs' => $correctAnswer['pairs'] ?? ''];
                    break;

                case 'fill_blank':
                    // Keep answer as string
                    $correctAnswer = ['answer' => $correctAnswer['answer'] ?? ''];
                    break;

                case 'short_answer':
                    // Keep model_answer and keywords
                    $correctAnswer = [
                        'model_answer' => $correctAnswer['model_answer'] ?? '',
                        'keywords' => $correctAnswer['keywords'] ?? '',
                    ];
                    // Handle numeric type (stored as short_answer)
                    if (isset($correctAnswer['tolerance'])) {
                        $correctAnswer['answer'] = $correctAnswer['answer'] ?? '';
                        $correctAnswer['tolerance'] = $correctAnswer['tolerance'];
                    }
                    break;
            }

            $validated['correct_answer'] = $correctAnswer;

            // Convert tags string to array if needed
            if (isset($validated['tags']) && is_string($validated['tags'])) {
                $validated['tags'] = array_map('trim', explode(',', $validated['tags']));
                $validated['tags'] = array_filter($validated['tags']); // Remove empty values
            }

            // Validate question data
            $errors = $this->quizService->validateQuestionData(
                $validated['question_type'],
                $validated
            );

            if (!empty($errors)) {
                return back()->withInput()
                    ->with('error', implode(', ', $errors));
            }

            $question = $this->quizService->addQuestion($quiz, $validated);

            return back()->with('success', 'تم إضافة السؤال بنجاح');

        } catch (\Exception $e) {
            return back()->withInput()
                ->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Show edit form for question
     */
    public function editQuestion($id, $questionId)
    {
        $quiz = Quiz::findOrFail($id);
        $question = QuizQuestion::where('quiz_id', $id)
            ->findOrFail($questionId);

        if (request()->wantsJson() || request()->header('Accept') === 'application/json') {
            return view('admin.quizzes.partials.question-form', [
                'quiz' => $quiz,
                'question' => $question
            ])->render();
        }

        return view('admin.quizzes.edit-question', compact('quiz', 'question'));
    }

    /**
     * Update question
     */
    public function updateQuestion(Request $request, $id, $questionId)
    {
        $question = QuizQuestion::where('quiz_id', $id)
            ->findOrFail($questionId);

        $validated = $request->validate([
            'question_type' => 'required|in:single_choice,multiple_choice,true_false,matching,ordering,fill_blank,short_answer,numeric',
            'question_text_ar' => 'required|string',
            'question_image_url' => 'nullable|url',
            'options' => 'nullable|array',
            'correct_answer' => 'required|array',
            'points' => 'required|integer|min:1',
            'explanation_ar' => 'nullable|string',
            'difficulty' => 'nullable|in:easy,medium,hard',
            'tags' => 'nullable',
        ]);

        try {
            // Map form question types to database enum values
            $questionTypeMap = [
                'single_choice' => 'mcq_single',
                'multiple_choice' => 'mcq_multiple',
                'true_false' => 'true_false',
                'matching' => 'matching',
                'ordering' => 'sequence',
                'fill_blank' => 'fill_blank',
                'short_answer' => 'short_answer',
                'numeric' => 'short_answer',
            ];

            $dbQuestionType = $questionTypeMap[$validated['question_type']] ?? $validated['question_type'];
            $validated['question_type'] = $dbQuestionType;

            // Process correct_answer based on question type
            $correctAnswer = $validated['correct_answer'];

            switch ($dbQuestionType) {
                case 'true_false':
                    // Convert string "true"/"false" to boolean
                    if (isset($correctAnswer['answer'])) {
                        $answer = $correctAnswer['answer'];
                        if ($answer === 'true' || $answer === '1' || $answer === 1) {
                            $correctAnswer = ['answer' => true];
                        } elseif ($answer === 'false' || $answer === '0' || $answer === 0) {
                            $correctAnswer = ['answer' => false];
                        }
                    }
                    break;

                case 'mcq_single':
                    // Ensure answer is an integer
                    if (isset($correctAnswer['answer'])) {
                        $correctAnswer = ['answer' => (int)$correctAnswer['answer']];
                    }
                    break;

                case 'mcq_multiple':
                    // Ensure answers is an array of integers
                    if (isset($correctAnswer['answers'])) {
                        $correctAnswer = ['answers' => array_map('intval', (array)$correctAnswer['answers'])];
                    }
                    break;

                case 'sequence':
                    // Parse order if it's a JSON string
                    if (isset($correctAnswer['order']) && is_string($correctAnswer['order'])) {
                        $order = json_decode($correctAnswer['order'], true);
                        $correctAnswer = ['order' => $order ?? []];
                    }
                    break;

                case 'matching':
                    // Keep pairs as string
                    $correctAnswer = ['pairs' => $correctAnswer['pairs'] ?? ''];
                    break;

                case 'fill_blank':
                    // Keep answer as string
                    $correctAnswer = ['answer' => $correctAnswer['answer'] ?? ''];
                    break;

                case 'short_answer':
                    // Keep model_answer and keywords
                    $correctAnswer = [
                        'model_answer' => $correctAnswer['model_answer'] ?? '',
                        'keywords' => $correctAnswer['keywords'] ?? '',
                    ];
                    // Handle numeric type (stored as short_answer)
                    if (isset($correctAnswer['tolerance'])) {
                        $correctAnswer['answer'] = $correctAnswer['answer'] ?? '';
                        $correctAnswer['tolerance'] = $correctAnswer['tolerance'];
                    }
                    break;
            }

            $validated['correct_answer'] = $correctAnswer;

            // Convert tags string to array if needed
            if (isset($validated['tags']) && is_string($validated['tags'])) {
                $validated['tags'] = array_map('trim', explode(',', $validated['tags']));
                $validated['tags'] = array_filter($validated['tags']); // Remove empty values
            }

            $this->quizService->updateQuestion($question, $validated);

            return back()->with('success', 'تم تحديث السؤال بنجاح');

        } catch (\Exception $e) {
            return back()->withInput()
                ->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Delete question
     */
    public function deleteQuestion($id, $questionId)
    {
        $question = QuizQuestion::where('quiz_id', $id)
            ->findOrFail($questionId);

        try {
            $this->quizService->deleteQuestion($question);

            return back()->with('success', 'تم حذف السؤال بنجاح');

        } catch (\Exception $e) {
            return back()->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Reorder questions
     */
    public function reorderQuestions(Request $request, $id)
    {
        $quiz = Quiz::findOrFail($id);

        $validated = $request->validate([
            'order' => 'required|array',
        ]);

        try {
            $this->quizService->reorderQuestions($quiz, $validated['order']);

            return response()->json([
                'success' => true,
                'message' => 'تم إعادة ترتيب الأسئلة بنجاح',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ: ' . $e->getMessage(),
            ], 400);
        }
    }

    /**
     * AJAX: Get years by phase
     */
    public function getYearsByPhase($phaseId)
    {
        $years = AcademicYear::where('academic_phase_id', $phaseId)
            ->orderBy('order')
            ->get(['id', 'name_ar']);

        return response()->json($years);
    }

    /**
     * AJAX: Get streams by year
     */
    public function getStreamsByYear($yearId)
    {
        $streams = AcademicStream::where('academic_year_id', $yearId)
            ->orderBy('order')
            ->get(['id', 'name_ar']);

        return response()->json($streams);
    }

    /**
     * AJAX: Get subjects by phase, year, and stream
     */
    public function getSubjects(Request $request)
    {
        $query = Subject::where('is_active', true);

        if ($request->filled('year_id')) {
            $query->where('academic_year_id', $request->year_id);
        }

        // Use forStream scope which checks academic_stream_ids JSON array
        if ($request->filled('stream_id')) {
            $query->forStream((int) $request->stream_id);
        }

        $subjects = $query->orderBy('name_ar')->get(['id', 'name_ar']);

        return response()->json($subjects);
    }

    /**
     * AJAX: Get chapters for a specific subject
     */
    public function getChapters($subjectId)
    {
        $chapters = ContentChapter::where('subject_id', $subjectId)
            ->orderBy('order')
            ->get(['id', 'title_ar']);

        return response()->json($chapters);
    }

    /**
     * Show the import questions form
     */
    public function showImportForm()
    {
        $phases = AcademicPhase::where('is_active', true)->orderBy('order')->get();
        $years = AcademicYear::where('is_active', true)->orderBy('order')->get();
        $streams = AcademicStream::where('is_active', true)->orderBy('order')->get();
        $subjects = Subject::where('is_active', true)->orderBy('name_ar')->get();

        return view('admin.quizzes.import', compact('phases', 'years', 'streams', 'subjects'));
    }

    /**
     * Process the Excel import and create quiz with questions
     */
    public function importQuestions(Request $request)
    {
        // Validate the request
        $validated = $request->validate([
            'phase_id' => 'required|exists:academic_phases,id',
            'academic_year_id' => 'required|exists:academic_years,id',
            'academic_stream_id' => 'nullable|exists:academic_streams,id',
            'subject_id' => 'required|exists:subjects,id',
            'chapter_id' => 'nullable|exists:content_chapters,id',
            'title_ar' => 'required|string|max:255',
            'description_ar' => 'nullable|string',
            'quiz_type' => 'required|in:practice,timed,exam',
            'difficulty_level' => 'required|in:easy,medium,hard',
            'passing_score' => 'required|integer|min:0|max:100',
            'time_limit_minutes' => 'nullable|integer|min:1',
            'estimated_duration_minutes' => 'nullable|integer|min:1',
            'shuffle_questions' => 'boolean',
            'shuffle_answers' => 'boolean',
            'show_correct_answers' => 'boolean',
            'allow_review' => 'boolean',
            'excel_file' => 'required|file|mimes:xlsx,xls,csv|max:10240', // 10MB max
        ]);

        try {
            // Import questions from Excel
            $import = new QuestionsImport();
            Excel::import($import, $request->file('excel_file'));

            // Check for errors
            if ($import->hasErrors()) {
                $errorMessages = collect($import->getErrors())
                    ->map(fn($error) => "السطر {$error['row']}: {$error['message']}")
                    ->join('<br>');

                return redirect()->back()
                    ->withInput()
                    ->with('error', "حدثت أخطاء أثناء استيراد الأسئلة:<br>{$errorMessages}");
            }

            $questions = $import->getQuestions();

            if (empty($questions)) {
                return redirect()->back()
                    ->withInput()
                    ->with('error', 'ملف Excel فارغ أو لا يحتوي على أسئلة صالحة');
            }

            // Prepare quiz data
            $quizData = [
                'subject_id' => $validated['subject_id'],
                'chapter_id' => $validated['chapter_id'] ?? null,
                'title_ar' => $validated['title_ar'],
                'description_ar' => $validated['description_ar'] ?? null,
                'quiz_type' => $validated['quiz_type'],
                'difficulty_level' => $validated['difficulty_level'],
                'passing_score' => $validated['passing_score'],
                'time_limit_minutes' => $validated['time_limit_minutes'] ?? null,
                'estimated_duration_minutes' => $validated['estimated_duration_minutes'] ?? null,
                'shuffle_questions' => $request->has('shuffle_questions'),
                'shuffle_answers' => $request->has('shuffle_answers'),
                'show_correct_answers' => $request->has('show_correct_answers'),
                'allow_review' => $request->has('allow_review'),
                'is_published' => false, // Draft by default
                'created_by' => auth()->id(),
            ];

            // Create quiz with imported questions using service
            $quiz = $this->quizService->createQuizWithImportedQuestions($quizData, $questions);

            return redirect()->route('admin.quizzes.questions', $quiz->id)
                ->with('success', "تم استيراد {$quiz->total_questions} سؤال بنجاح وإنشاء الاختبار '{$quiz->title_ar}'");

        } catch (\Maatwebsite\Excel\Validators\ValidationException $e) {
            $failures = $e->failures();
            $errorMessages = collect($failures)
                ->map(fn($failure) => "السطر {$failure->row()}: " . implode(', ', $failure->errors()))
                ->join('<br>');

            return redirect()->back()
                ->withInput()
                ->with('error', "أخطاء في التحقق من صحة البيانات:<br>{$errorMessages}");

        } catch (\Exception $e) {
            \Log::error('Quiz import error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);

            return redirect()->back()
                ->withInput()
                ->with('error', 'حدث خطأ أثناء استيراد الأسئلة: ' . $e->getMessage());
        }
    }

    /**
     * Download the Excel template for importing questions
     */
    public function downloadTemplate()
    {
        $templatePath = storage_path('app/templates/questions_import_template.xlsx');

        if (!file_exists($templatePath)) {
            $guidePath = storage_path('app/templates/TEMPLATE_CREATION_GUIDE.md');
            $message = 'ملف القالب غير موجود. يرجى إنشاء القالب أولاً باتباع دليل الإنشاء في:<br><code>storage/app/templates/TEMPLATE_CREATION_GUIDE.md</code><br><br>أو راجع الوثائق في: <code>docs/bank_questions/</code>';

            return redirect()->back()
                ->with('error', $message);
        }

        return response()->download($templatePath, 'questions_template.xlsx');
    }

    /**
     * Get quizzes by subject (AJAX endpoint for content creation)
     */
    public function getQuizzesBySubject($subjectId)
    {
        $quizzes = Quiz::where('subject_id', $subjectId)
            ->where('is_published', true)
            ->select('id', 'title_ar', 'difficulty_level', 'quiz_type')
            ->withCount('questions as total_questions')
            ->orderBy('title_ar')
            ->get();

        return response()->json($quizzes);
    }
}
