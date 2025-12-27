<?php

namespace App\Imports;

use Maatwebsite\Excel\Concerns\WithMultipleSheets;
use PhpOffice\PhpSpreadsheet\IOFactory;

class QuizExcelImport implements WithMultipleSheets
{
    protected array $sheetImports = [];
    protected string $filePath;
    protected array $sheetNames = [];

    public function __construct(string $filePath)
    {
        $this->filePath = $filePath;
        $this->initializeSheets();
    }

    protected function initializeSheets(): void
    {
        $spreadsheet = IOFactory::load($this->filePath);
        $this->sheetNames = $spreadsheet->getSheetNames();

        foreach ($this->sheetNames as $sheetName) {
            $this->sheetImports[$sheetName] = new QuizSheetImport($sheetName);
        }
    }

    public function sheets(): array
    {
        return $this->sheetImports;
    }

    public function getSheetNames(): array
    {
        return $this->sheetNames;
    }

    public function getSheetImports(): array
    {
        return $this->sheetImports;
    }

    public function getAllQuestions(): array
    {
        $result = [];
        foreach ($this->sheetImports as $sheetName => $import) {
            $questions = $import->getQuestions();
            if (!empty($questions)) {
                $result[$sheetName] = $questions;
            }
        }
        return $result;
    }

    public function getAllErrors(): array
    {
        $result = [];
        foreach ($this->sheetImports as $sheetName => $import) {
            $errors = $import->getErrors();
            if (!empty($errors)) {
                $result[$sheetName] = $errors;
            }
        }
        return $result;
    }

    public function getTotalQuestions(): int
    {
        $total = 0;
        foreach ($this->sheetImports as $import) {
            $total += count($import->getQuestions());
        }
        return $total;
    }

    public function hasErrors(): bool
    {
        foreach ($this->sheetImports as $import) {
            if ($import->hasErrors()) {
                return true;
            }
        }
        return false;
    }
}
