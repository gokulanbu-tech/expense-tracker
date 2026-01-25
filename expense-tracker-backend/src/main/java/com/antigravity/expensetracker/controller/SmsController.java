package com.antigravity.expensetracker.controller;

import com.antigravity.expensetracker.dto.SmsDto;
import com.antigravity.expensetracker.model.SmsMessage;
import com.antigravity.expensetracker.repository.SmsMessageRepository;
import com.antigravity.expensetracker.service.SmsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/sms")
@CrossOrigin(origins = "http://localhost:5173", methods = { RequestMethod.GET, RequestMethod.POST,
        RequestMethod.OPTIONS })
public class SmsController {

    @Autowired
    private SmsService smsService;

    @Autowired
    private SmsMessageRepository smsMessageRepository;

    @PostMapping
    public ResponseEntity<?> receiveSms(@RequestBody SmsDto smsDto) {
        try {
            // Check for idempotency here to distinguish between OK (200) and CREATED (201)
            // or let the service handle it and just return the result.
            // To maintain original behavior:
            Optional<SmsMessage> existing = smsMessageRepository.findByMessageId(smsDto.getMessageId());
            if (existing.isPresent()) {
                return ResponseEntity.ok(existing.get());
            }

            SmsMessage savedMessage = smsService.processSms(smsDto);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedMessage);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        } catch (RuntimeException e) {
            if (e.getMessage().contains("Unauthorized")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Error: " + e.getMessage());
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error: Failed to process SMS message. " + e.getMessage());
        }
    }

    @GetMapping
    public ResponseEntity<?> getAllSms(@RequestParam(required = false) String senderNumber) {
        if (senderNumber != null && !senderNumber.trim().isEmpty()) {
            return ResponseEntity.ok(smsService.getSmsBySender(senderNumber));
        }
        return ResponseEntity.ok(smsService.getAllSms());
    }
}
