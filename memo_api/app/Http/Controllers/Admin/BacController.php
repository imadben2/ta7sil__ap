<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\BacService;
use App\Services\BacSimulationService;
use App\Models\BacSubject;
use App\Models\BacYear;
use App\Models\BacSession;
use App\Models\Subject;
use App\Models\AcademicStream;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Yajra\DataTables\Facades\DataTables;

class BacController extends Controller
{
    protected $bacService;
    protected $simulationService;

    public function __construct(BacService $bacService, BacSimulationService $simulationService)
    {
        $this->bacService = $bacService;
        $this->simulationService = $simulationService;
    }

    /**
     * Display a listing of BAC subjects
     */
    public function index(Request $request)
    {
        if ($request->ajax()) {
            $query = BacSubject::select('bac_subjects.*')
                ->with(['bacYear', 'bacSession', 'subject', 'academicStream']);

            // Apply filters if provided
            if ($request->filled('year_id')) {
                $query->where('bac_year_id', $request->year_id);
            }
            if ($request->filled('session_id')) {
                $query->where('bac_session_id', $request->session_id);
            }
            if ($request->filled('subject_id')) {
                $query->where('subject_id', $request->subject_id);
            }
            if ($request->filled('stream_id')) {
                $query->where('academic_stream_id', $request->stream_id);
            }

            return DataTables::of($query)
                ->addColumn('real_id', function($bacSubject) {
                    return $bacSubject->id;
                })
                ->addColumn('year', function($bacSubject) {
                    return $bacSubject->bacYear->year ?? '-';
                })
                ->addColumn('session', function($bacSubject) {
                    return $bacSubject->bacSession->name_ar ?? '-';
                })
                ->addColumn('subject', function($bacSubject) {
                    return $bacSubject->subject->name_ar ?? '-';
                })
                ->addColumn('stream', function($bacSubject) {
                    return $bacSubject->academicStream->name_ar ?? '-';
                })
                ->addColumn('title', function($bacSubject) {
                    $html = '<div class="text-sm font-medium text-gray-900">[ID: ' . $bacSubject->getKey() . '] ' . $bacSubject->title_ar . '</div>';
                    if ($bacSubject->correction_file_path) {
                        $html .= '<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800 mt-1">';
                        $html .= '<i class="fas fa-check-circle mr-1"></i> يحتوي على التصحيح';
                        $html .= '</span>';
                    }
                    return $html;
                })
                ->addColumn('duration', function($bacSubject) {
                    return $bacSubject->duration_minutes . ' دقيقة';
                })
                ->addColumn('stats', function($bacSubject) {
                    return '<div class="flex flex-col gap-1 text-sm text-gray-500">
                        <span><i class="fas fa-eye text-blue-500 mr-1"></i> ' . $bacSubject->views_count . ' مشاهدة</span>
                        <span><i class="fas fa-download text-green-500 mr-1"></i> ' . $bacSubject->downloads_count . ' تنزيل</span>
                    </div>';
                })
                ->addColumn('actions', function($bacSubject) {
                    $id = $bacSubject->getKey();
                    return '<div class="flex gap-2">
                        <a href="' . route('admin.bac.show', ['id' => $id]) . '" class="text-blue-600 hover:text-blue-900" title="عرض">
                            <i class="fas fa-eye"></i>
                        </a>
                        <a href="' . route('admin.bac.edit', ['id' => $id]) . '" class="text-indigo-600 hover:text-indigo-900" title="تعديل">
                            <i class="fas fa-edit"></i>
                        </a>
                        <form method="POST" action="' . route('admin.bac.destroy', ['id' => $id]) . '"
                              onsubmit="return confirm(\'هل أنت متأكد من حذف هذا الموضوع؟\')" class="inline">
                            ' . csrf_field() . method_field('DELETE') . '
                            <button type="submit" class="text-red-600 hover:text-red-900" title="حذف">
                                <i class="fas fa-trash"></i>
                            </button>
                        </form>
                    </div>';
                })
                ->rawColumns(['title', 'stats', 'actions'])
                ->make(true);
        }

        $years = BacYear::active()->orderBy('year', 'desc')->get();
        $sessions = BacSession::all();
        $subjects = Subject::orderBy('name_ar')->get();
        $streams = AcademicStream::orderBy('name_ar')->get();

        return view('admin.bac.index', compact('years', 'sessions', 'subjects', 'streams'));
    }

    /**
     * Show the form for creating a new BAC subject
     */
    public function create()
    {
        $years = BacYear::active()->orderBy('year', 'desc')->get();

        return view('admin.bac.create', compact('years'));
    }

    /**
     * Store a newly created BAC subject in storage
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'bac_year_id' => 'required|exists:bac_years,id',
            'bac_session_id' => 'required|exists:bac_sessions,id',
            'subject_id' => 'required|exists:subjects,id',
            'academic_stream_id' => 'required|exists:academic_streams,id',
            'title_ar' => 'required|string|max:255',
            'duration_minutes' => 'required|integer|min:1|max:300',
            'file' => 'required|file|mimes:pdf|max:10240',
            'correction_file' => 'nullable|file|mimes:pdf|max:10240',
            'chapters' => 'nullable|array',
            'chapters.*.title_ar' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        try {
            $bacSubject = $this->bacService->createBacSubject(
                $request->except(['file', 'correction_file', 'chapters']),
                $request->file('file'),
                $request->file('correction_file')
            );

            // Add chapters if provided
            if ($request->has('chapters')) {
                $this->bacService->addChapters($bacSubject, $request->input('chapters'));
            }

            return redirect()->route('admin.bac.show', $bacSubject->id)
                ->with('success', 'تم إضافة موضوع البكالوريا بنجاح');
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'حدث خطأ: ' . $e->getMessage())
                ->withInput();
        }
    }

    /**
     * Display the specified BAC subject
     */
    public function show($id)
    {
        $bacSubject = $this->bacService->getBacSubjectById($id);

        return view('admin.bac.show', compact('bacSubject'));
    }

    /**
     * Show the form for editing the specified BAC subject
     */
    public function edit($id)
    {
        $bacSubject = $this->bacService->getBacSubjectById($id);
        $years = BacYear::active()->orderBy('year', 'desc')->get();

        return view('admin.bac.edit', compact('bacSubject', 'years'));
    }

    /**
     * Update the specified BAC subject in storage
     */
    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'bac_year_id' => 'required|exists:bac_years,id',
            'bac_session_id' => 'required|exists:bac_sessions,id',
            'subject_id' => 'required|exists:subjects,id',
            'academic_stream_id' => 'required|exists:academic_streams,id',
            'title_ar' => 'required|string|max:255',
            'duration_minutes' => 'required|integer|min:1|max:300',
            'file' => 'nullable|file|mimes:pdf|max:10240',
            'correction_file' => 'nullable|file|mimes:pdf|max:10240',
            'chapters' => 'nullable|array',
            'chapters.*.title_ar' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        try {
            $bacSubject = BacSubject::findOrFail($id);

            $this->bacService->updateBacSubject(
                $bacSubject,
                $request->except(['file', 'correction_file', 'chapters']),
                $request->file('file'),
                $request->file('correction_file')
            );

            // Update chapters if provided
            if ($request->has('chapters')) {
                $this->bacService->updateChapters($bacSubject, $request->input('chapters'));
            }

            return redirect()->route('admin.bac.show', $bacSubject->id)
                ->with('success', 'تم تحديث موضوع البكالوريا بنجاح');
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'حدث خطأ: ' . $e->getMessage())
                ->withInput();
        }
    }

    /**
     * Remove the specified BAC subject from storage
     */
    public function destroy($id)
    {
        try {
            $bacSubject = BacSubject::findOrFail($id);
            $this->bacService->deleteBacSubject($bacSubject);

            return redirect()->route('admin.bac.index')
                ->with('success', 'تم حذف موضوع البكالوريا بنجاح');
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'حدث خطأ: ' . $e->getMessage());
        }
    }

    /**
     * Display statistics dashboard
     */
    public function statistics()
    {
        $statistics = $this->bacService->getStatistics();
        $simulationStats = $this->simulationService->getSimulationStatistics();

        return view('admin.bac.statistics', compact('statistics', 'simulationStats'));
    }

    /**
     * Manage BAC years
     */
    public function years()
    {
        $years = BacYear::orderBy('year', 'desc')->get();

        return view('admin.bac.years', compact('years'));
    }

    /**
     * Store a new BAC year
     */
    public function storeYear(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'year' => 'required|integer|unique:bac_years,year',
            'is_active' => 'boolean',
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        BacYear::create($request->all());

        return redirect()->route('admin.bac.years')
            ->with('success', 'تم إضافة السنة بنجاح');
    }

    /**
     * Toggle BAC year active status
     */
    public function toggleYearStatus($id)
    {
        $year = BacYear::findOrFail($id);
        $year->is_active = !$year->is_active;
        $year->save();

        return redirect()->back()
            ->with('success', 'تم تحديث حالة السنة بنجاح');
    }

    /**
     * Delete BAC year
     */
    public function destroyYear($id)
    {
        try {
            $year = BacYear::findOrFail($id);
            $year->delete();

            return redirect()->route('admin.bac.years')
                ->with('success', 'تم حذف السنة بنجاح');
        } catch (\Exception $e) {
            return redirect()->back()
                ->with('error', 'لا يمكن حذف السنة لأنها مرتبطة بمواضيع');
        }
    }

    /**
     * AJAX: Get sessions by year
     */
    public function getSessionsByYear($yearId)
    {
        $sessions = BacSession::all(['id', 'name_ar']);
        return response()->json($sessions);
    }

    /**
     * AJAX: Get subjects by stream
     */
    public function getSubjectsByStream($streamId)
    {
        $subjects = Subject::forStream($streamId)
            ->orderBy('name_ar')
            ->get(['id', 'name_ar', 'academic_stream_ids']);

        return response()->json($subjects);
    }

    /**
     * AJAX: Get streams
     */
    public function getStreams()
    {
        $streams = AcademicStream::orderBy('name_ar')
            ->get(['id', 'name_ar']);

        return response()->json($streams);
    }
}
