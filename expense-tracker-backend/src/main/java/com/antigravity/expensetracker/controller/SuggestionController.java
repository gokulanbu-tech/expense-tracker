package com.antigravity.expensetracker.controller;

import com.antigravity.expensetracker.dto.Suggestion;
import com.antigravity.expensetracker.service.SuggestionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/suggestions")
public class SuggestionController {

    private final SuggestionService suggestionService;

    @Autowired
    public SuggestionController(SuggestionService suggestionService) {
        this.suggestionService = suggestionService;
    }

    @GetMapping
    public List<Suggestion> getSuggestions(@RequestParam UUID userId) {
        return suggestionService.getSuggestions(userId);
    }
}
