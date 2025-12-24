<?php

namespace App\Helpers;

class ArabicHelper
{
    /**
     * Prepare Arabic text for PDF rendering with DOMPDF
     * This reverses the text to compensate for DOMPDF's lack of RTL support
     */
    public static function prepareForPDF($text)
    {
        if (empty($text)) {
            return '';
        }

        // Use mb_string functions for proper Unicode handling
        $text = mb_convert_encoding($text, 'UTF-8', 'UTF-8');

        // Split text by spaces to handle words separately
        $words = explode(' ', $text);
        $reversedWords = [];

        foreach ($words as $word) {
            // Check if word contains Arabic characters
            if (preg_match('/[\x{0600}-\x{06FF}]/u', $word)) {
                // Reverse Arabic word using mb_substr for proper Unicode handling
                $reversed = '';
                $length = mb_strlen($word, 'UTF-8');
                for ($i = $length - 1; $i >= 0; $i--) {
                    $reversed .= mb_substr($word, $i, 1, 'UTF-8');
                }
                $reversedWords[] = $reversed;
            } else {
                // Keep non-Arabic text as is
                $reversedWords[] = $word;
            }
        }

        // Reverse the order of words
        return implode(' ', array_reverse($reversedWords));
    }

    /**
     * Prepare multiple fields in an object for PDF
     */
    public static function prepareObjectForPDF($object, $fields)
    {
        foreach ($fields as $field) {
            if (isset($object->$field)) {
                $object->{$field . '_pdf'} = self::prepareForPDF($object->$field);
            }
        }
        return $object;
    }
}
