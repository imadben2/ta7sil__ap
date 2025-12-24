<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Compress HTTP responses using gzip
 * Reduces bandwidth and improves load times
 */
class CompressResponse
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        // Only compress if:
        // 1. Client accepts gzip encoding
        // 2. Response is compressible (text-based content)
        // 3. Response is not already compressed
        if (
            !str_contains($request->header('Accept-Encoding', ''), 'gzip') ||
            $response->headers->has('Content-Encoding') ||
            !$this->shouldCompress($response)
        ) {
            return $response;
        }

        // Get the content
        $content = $response->getContent();

        // Only compress if content is large enough (>1KB) to benefit from compression
        if (strlen($content) < 1024) {
            return $response;
        }

        // Compress the content
        $compressedContent = gzencode($content, 6); // Level 6 is a good balance

        if ($compressedContent === false) {
            return $response;
        }

        // Set compressed content and headers
        $response->setContent($compressedContent);
        $response->headers->set('Content-Encoding', 'gzip');
        $response->headers->set('Content-Length', strlen($compressedContent));
        $response->headers->set('Vary', 'Accept-Encoding');

        return $response;
    }

    /**
     * Determine if the response should be compressed
     */
    private function shouldCompress(Response $response): bool
    {
        $contentType = $response->headers->get('Content-Type', '');

        // List of compressible content types
        $compressibleTypes = [
            'text/html',
            'text/plain',
            'text/css',
            'text/javascript',
            'application/json',
            'application/javascript',
            'application/xml',
            'text/xml',
            'application/xhtml+xml',
        ];

        foreach ($compressibleTypes as $type) {
            if (str_contains($contentType, $type)) {
                return true;
            }
        }

        return false;
    }
}
