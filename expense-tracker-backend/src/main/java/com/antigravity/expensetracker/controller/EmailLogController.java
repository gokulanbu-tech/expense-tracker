package com.antigravity.expensetracker.controller;

import com.antigravity.expensetracker.model.EmailLog;
import com.antigravity.expensetracker.model.User;
import com.antigravity.expensetracker.repository.EmailLogRepository;
import com.antigravity.expensetracker.repository.UserRepository;
import com.antigravity.expensetracker.service.EmailParsingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/emails")
@CrossOrigin(originPatterns = "*")
public class EmailLogController {

    @Autowired
    private EmailLogRepository emailLogRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EmailParsingService emailParsingService;

    @PostMapping
    public ResponseEntity<?> saveEmail(@RequestBody Map<String, Object> payload) {
        try {
            @SuppressWarnings("unchecked")
            String userIdStr = (String) ((Map<String, Object>) payload.get("user")).get("id");
            UUID userId = UUID.fromString(userIdStr);

            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            String messageId = (String) payload.get("messageId");
            if (messageId == null || messageId.isEmpty()) {
                return ResponseEntity.badRequest().body("Message ID is required");
            }

            if (emailLogRepository.existsByMessageId(messageId)) {
                System.out.println("Duplicate messageId ignored: " + messageId);
                return ResponseEntity.ok().body("Duplicate email ignored: " + messageId);
            }

            String sender = (String) payload.get("sender");
            String subject = (String) payload.get("subject");

            String dateStr = (String) payload.get("receivedAt");
            LocalDateTime receivedAt;
            if (dateStr != null) {
                try {
                    // Handle ends with Z or has offset
                    if (dateStr.endsWith("Z")) {
                        receivedAt = java.time.ZonedDateTime.parse(dateStr).toLocalDateTime();
                    } else {
                        receivedAt = LocalDateTime.parse(dateStr);
                    }
                } catch (Exception e) {
                    // Fallback for date parsing error
                    System.out.println("Date parse error: " + e.getMessage());
                    receivedAt = LocalDateTime.now();
                }
            } else {
                receivedAt = LocalDateTime.now();
            }

            if (emailLogRepository.existsBySenderAndSubjectAndReceivedAt(sender, subject, receivedAt)) {
                System.out.println("Duplicate match found for: " + subject);
                return ResponseEntity.ok().body("Duplicate email ignored (content match): " + subject);
            }

            EmailLog emailLog = new EmailLog();
            emailLog.setUser(user);
            emailLog.setMessageId(messageId);
            emailLog.setSubject(subject);
            emailLog.setBody((String) payload.get("body"));
            emailLog.setSender(sender);
            emailLog.setReceivedAt(receivedAt);

            EmailLog savedLog = emailLogRepository.save(emailLog);

            // Trigger parsing
            emailParsingService.parseAndCreateExpense(savedLog);

            return ResponseEntity.ok(savedLog);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error saving email: " + e.getMessage());
        }
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getUserEmails(@PathVariable UUID userId) {
        return ResponseEntity.ok(emailLogRepository.findByUserId(userId));
    }
}
