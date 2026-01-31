package com.antigravity.expensetracker.controller;

import com.antigravity.expensetracker.dto.EmailParseRequest;
import com.antigravity.expensetracker.dto.ExpenseExtractionResponse;
import com.antigravity.expensetracker.service.GeminiService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/emails")
@RequiredArgsConstructor
public class EmailParsingController {

    private final GeminiService geminiService;

    @PostMapping("/parse")
    public ResponseEntity<ExpenseExtractionResponse> parseEmail(@RequestBody EmailParseRequest request) {
        ExpenseExtractionResponse response = geminiService.parseEmail(request);
        if (response.isError()) {
            return ResponseEntity.badRequest().body(response);
        }
        return ResponseEntity.ok(response);
    }
}
