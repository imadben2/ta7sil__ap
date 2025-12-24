<?php

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$content = file_get_contents('../quiz.md');

// Split by question markers
$pattern = '/(?:Question\s*(\d+)\s*:|السؤال\s*(\d+))/u';
$parts = preg_split($pattern, $content, -1, PREG_SPLIT_DELIM_CAPTURE | PREG_SPLIT_NO_EMPTY);

$questions = [];
$i = 0;
while ($i < count($parts)) {
    // Skip numeric parts (question numbers)
    if (is_numeric(trim($parts[$i]))) {
        $i++;
        continue;
    }

    $questionContent = trim($parts[$i]);
    if (empty($questionContent)) {
        $i++;
        continue;
    }

    $question = parseQuestionBlock($questionContent);
    if ($question) {
        $questions[] = $question;
    }

    $i++;
}

echo "Total questions parsed: " . count($questions) . PHP_EOL;

// Check for duplicate options
$duplicateCount = 0;
foreach ($questions as $idx => $q) {
    $optionTexts = array_column($q['options'], 'text');
    $uniqueTexts = array_unique($optionTexts);

    if (count($optionTexts) !== count($uniqueTexts)) {
        $duplicateCount++;
        echo "Question " . ($idx + 1) . " has duplicate options:" . PHP_EOL;
        echo "  Text: " . mb_substr($q['question_text'], 0, 50) . "..." . PHP_EOL;
        $counts = array_count_values($optionTexts);
        foreach ($counts as $text => $count) {
            if ($count > 1) {
                echo "  Duplicate: '{$text}' appears {$count} times" . PHP_EOL;
            }
        }
        echo "  All options:" . PHP_EOL;
        foreach ($q['options'] as $opt) {
            echo "    [{$opt['letter']}] {$opt['text']}" . PHP_EOL;
        }
        echo PHP_EOL;
    }
}

echo "Total questions with duplicates: {$duplicateCount}" . PHP_EOL;

function parseQuestionBlock(string $content): ?array
{
    $lines = array_filter(array_map('trim', explode("\n", $content)));
    $lines = array_values($lines);

    if (empty($lines)) {
        return null;
    }

    // First line(s) until we hit an option is the question text
    $questionText = '';
    $options = [];
    $correctAnswer = null;

    foreach ($lines as $line) {
        // Skip separator lines
        if (preg_match('/^[_\-=]{3,}$/', $line)) {
            continue;
        }

        // Check for correct answer line (English or Arabic)
        if (preg_match('/^(?:Correct answer|الإجابة الصحيحة)\s*:\s*([A-Da-d])/ui', $line, $match)) {
            $correctAnswer = strtoupper($match[1]);
            continue;
        }

        // Check for option line (A), B), C), D) or A. B. C. D.)
        if (preg_match('/^([A-Da-d])[\)\.]\s*(.+)$/u', $line, $match)) {
            $optionLetter = strtoupper($match[1]);
            $optionText = trim($match[2]);

            $options[] = [
                'letter' => $optionLetter,
                'text' => $optionText,
                'is_correct' => false,
            ];
            continue;
        }

        // Otherwise it's part of the question text
        if (empty($options)) {
            $questionText .= ($questionText ? ' ' : '') . $line;
        }
    }

    // Clean up question text
    $questionText = trim($questionText);

    // If no question text or options, skip
    if (empty($questionText) || count($options) < 2) {
        return null;
    }

    // Set correct answer
    if ($correctAnswer) {
        foreach ($options as &$option) {
            if ($option['letter'] === $correctAnswer) {
                $option['is_correct'] = true;
            }
        }
        unset($option); // CRITICAL: break reference to avoid PHP foreach bug
    }

    // Check if we have at least one correct answer
    $hasCorrect = false;
    foreach ($options as $opt) {
        if ($opt['is_correct']) {
            $hasCorrect = true;
            break;
        }
    }

    if (!$hasCorrect) {
        return null;
    }

    return [
        'question_text' => $questionText,
        'options' => $options,
        'question_type' => 'mcq_single',
    ];
}
