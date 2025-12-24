<?php

namespace App\Services;

use SimpleXMLElement;
use ZipArchive;

/**
 * Parser for extracting tables from Word documents (.docx)
 *
 * Word documents store their content in XML format inside a ZIP archive.
 * This class extracts table structures from the document.xml file.
 */
class WordTableParser
{
    protected const WORD_NAMESPACE = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main';

    /**
     * Parse all tables from a Word document
     *
     * @param string $filePath Path to the .docx file
     * @return array Array of tables, each containing rows of cells
     * @throws \Exception If file cannot be read
     */
    public function parseTables(string $filePath): array
    {
        $content = $this->getDocumentXml($filePath);
        $xml = simplexml_load_string($content);

        if ($xml === false) {
            throw new \Exception("Cannot parse document XML");
        }

        $xml->registerXPathNamespace('w', self::WORD_NAMESPACE);

        $tables = [];
        foreach ($xml->xpath('//w:tbl') as $table) {
            $parsedTable = $this->parseTable($table);
            if (!empty($parsedTable)) {
                $tables[] = $parsedTable;
            }
        }

        return $tables;
    }

    /**
     * Parse a single table element
     *
     * @param SimpleXMLElement $table The table XML element
     * @return array Array of rows, each containing cell values
     */
    protected function parseTable(SimpleXMLElement $table): array
    {
        $table->registerXPathNamespace('w', self::WORD_NAMESPACE);
        $rows = [];

        foreach ($table->xpath('.//w:tr') as $tr) {
            $row = $this->parseRow($tr);
            if (!empty($row)) {
                $rows[] = $row;
            }
        }

        return $rows;
    }

    /**
     * Parse a table row
     *
     * @param SimpleXMLElement $row The row XML element
     * @return array Array of cell text values
     */
    protected function parseRow(SimpleXMLElement $row): array
    {
        $row->registerXPathNamespace('w', self::WORD_NAMESPACE);
        $cells = [];

        foreach ($row->xpath('.//w:tc') as $tc) {
            $cells[] = $this->parseCellContent($tc);
        }

        return $cells;
    }

    /**
     * Extract text content from a table cell
     *
     * Handles multiple paragraphs and text runs within a cell,
     * preserving important markers like checkmarks.
     *
     * @param SimpleXMLElement $cell The cell XML element
     * @return string Trimmed text content of the cell
     */
    protected function parseCellContent(SimpleXMLElement $cell): string
    {
        $cell->registerXPathNamespace('w', self::WORD_NAMESPACE);
        $texts = [];

        // Get all text elements within the cell
        foreach ($cell->xpath('.//w:t') as $t) {
            $text = (string) $t;
            if ($text !== '') {
                $texts[] = $text;
            }
        }

        // Join and normalize whitespace
        $content = implode('', $texts);
        $content = preg_replace('/\s+/', ' ', $content);

        return trim($content);
    }

    /**
     * Get the raw document.xml content from a .docx file
     *
     * @param string $filePath Path to the .docx file
     * @return string XML content
     * @throws \Exception If file cannot be read
     */
    protected function getDocumentXml(string $filePath): string
    {
        if (!file_exists($filePath)) {
            throw new \Exception("File not found: {$filePath}");
        }

        if (!str_ends_with(strtolower($filePath), '.docx')) {
            throw new \Exception("Only .docx files are supported");
        }

        $zip = new ZipArchive();
        $result = $zip->open($filePath);

        if ($result !== true) {
            throw new \Exception("Cannot open Word document: error code {$result}");
        }

        $content = $zip->getFromName('word/document.xml');
        $zip->close();

        if ($content === false) {
            throw new \Exception("Cannot read document content");
        }

        return $content;
    }

    /**
     * Get paragraphs (non-table text) from the document
     * Useful for extracting subject headers that may be outside tables
     *
     * @param string $filePath Path to the .docx file
     * @return array Array of paragraph texts
     */
    public function getParagraphs(string $filePath): array
    {
        $content = $this->getDocumentXml($filePath);
        $xml = simplexml_load_string($content);

        if ($xml === false) {
            return [];
        }

        $xml->registerXPathNamespace('w', self::WORD_NAMESPACE);

        $paragraphs = [];

        // Get paragraphs that are NOT inside tables
        // This is useful for subject headers like "• العلوم الطبيعية:"
        foreach ($xml->xpath('//w:body/w:p') as $p) {
            $p->registerXPathNamespace('w', self::WORD_NAMESPACE);
            $texts = [];

            foreach ($p->xpath('.//w:t') as $t) {
                $texts[] = (string) $t;
            }

            $text = trim(implode('', $texts));
            if (!empty($text)) {
                $paragraphs[] = $text;
            }
        }

        return $paragraphs;
    }
}
