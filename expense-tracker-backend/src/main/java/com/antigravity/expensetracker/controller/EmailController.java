package com.antigravity.expensetracker.controller;

import com.antigravity.expensetracker.dto.EmailDto;
import com.antigravity.expensetracker.model.SmsMessage;
import com.antigravity.expensetracker.service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/email")
@CrossOrigin(origins = "http://localhost:5173")
public class EmailController {

    @Autowired
    private EmailService emailService;

    @PostMapping("/receive")
    public ResponseEntity<?> receiveEmail(@RequestBody EmailDto emailDto) {
        try {
            if (emailDto.getFrom() == null || emailDto.getBody() == null) {
                return ResponseEntity.badRequest().body("Error: From and Body are required.");
            }

            SmsMessage processedMessage = emailService.processEmail(emailDto);
            return ResponseEntity.status(HttpStatus.CREATED).body(processedMessage);

        } catch (RuntimeException e) {
            if (e.getMessage().contains("Unauthorized")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Error: " + e.getMessage());
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error: Failed to process email. " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error: An unexpected error occurred. " + e.getMessage());
        }
    }
}
