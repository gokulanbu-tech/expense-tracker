package com.antigravity.expensetracker.controller;

import com.antigravity.expensetracker.dto.ChatRequest;
import com.antigravity.expensetracker.dto.ChatResponse;
import com.antigravity.expensetracker.service.ChatService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/chat")
@CrossOrigin(originPatterns = "*") // Allow all origins with credentials support
public class ChatController {

    private final ChatService chatService;

    public ChatController(ChatService chatService) {
        this.chatService = chatService;
    }

    @PostMapping("/ask")
    public ResponseEntity<ChatResponse> ask(@RequestParam UUID userId, @RequestBody ChatRequest request) {
        ChatResponse response = chatService.processUserMessage(userId, request.getMessage(), request.getHistory());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/status")
    public ResponseEntity<Integer> getStatus(@RequestParam UUID userId) {
        return ResponseEntity.ok(chatService.getRemainingQuota(userId));
    }
}
