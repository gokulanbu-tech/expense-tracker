package com.antigravity.expensetracker.service;

import com.antigravity.expensetracker.dto.SmsDto;
import com.antigravity.expensetracker.model.SmsMessage;
import com.antigravity.expensetracker.model.User;
import com.antigravity.expensetracker.repository.SmsMessageRepository;
import com.antigravity.expensetracker.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class SmsService {

    @Autowired
    private SmsMessageRepository smsMessageRepository;

    @Autowired
    private UserRepository userRepository;

    public SmsMessage processSms(SmsDto smsDto) {
        // 1. Validation of required fields
        validateSmsDto(smsDto);

        // 2. Authorization: verify if sender is a registered user
        Optional<User> userOptional = userRepository.findByMobileNumber(smsDto.getSenderNumber());
        if (userOptional.isEmpty()) {
            throw new RuntimeException("Unauthorized: Sender phone number not recognized.");
        }

        // 3. Enforce maximum message length
        if (smsDto.getContent().length() > 2000) {
            throw new IllegalArgumentException("SMS content exceeds maximum allowed length (2000 characters).");
        }

        // 4. Validate attachment data
        if (smsDto.getAttachmentInfo() != null && smsDto.getAttachmentInfo().length() > 5000) {
            throw new IllegalArgumentException("Attachment metadata is too large.");
        }

        // 5. Idempotency check: prevent duplicate storage using client-provided
        // messageId
        Optional<SmsMessage> existing = smsMessageRepository.findByMessageId(smsDto.getMessageId());
        if (existing.isPresent()) {
            return existing.get();
        }

        // 6. Sanitize content
        String sanitizedContent = sanitize(smsDto.getContent());

        // 7. Create and store the message with metadata
        SmsMessage smsMessage = new SmsMessage();
        smsMessage.setMessageId(smsDto.getMessageId());
        smsMessage.setContent(sanitizedContent);
        smsMessage.setSenderNumber(smsDto.getSenderNumber());
        smsMessage.setRecipientNumber(smsDto.getRecipientNumber());
        smsMessage.setDeviceTimestamp(smsDto.getTimestamp() != null ? smsDto.getTimestamp() : LocalDateTime.now());
        smsMessage.setAttachmentInfo(smsDto.getAttachmentInfo());
        smsMessage.setEncryptionStatus(
                smsDto.getEncryptionStatus() != null ? smsDto.getEncryptionStatus() : "NONE");
        smsMessage.setDeliveryStatus("PERSISTED");
        smsMessage.setCreatedAt(LocalDateTime.now());

        return smsMessageRepository.save(smsMessage);
    }

    public java.util.List<SmsMessage> getAllSms() {
        return smsMessageRepository.findAll();
    }

    public java.util.List<SmsMessage> getSmsBySender(String senderNumber) {
        return smsMessageRepository.findBySenderNumber(senderNumber);
    }

    private void validateSmsDto(SmsDto smsDto) {
        if (smsDto.getMessageId() == null || smsDto.getMessageId().trim().isEmpty()) {
            throw new IllegalArgumentException("messageId (unique ID) is required for idempotency.");
        }
        if (smsDto.getContent() == null || smsDto.getContent().trim().isEmpty()) {
            throw new IllegalArgumentException("SMS content is required.");
        }
        if (smsDto.getSenderNumber() == null || smsDto.getSenderNumber().trim().isEmpty()) {
            throw new IllegalArgumentException("Sender phone number is required.");
        }
        if (!smsDto.getSenderNumber().matches("^\\+?[0-9]{10,15}$")) {
            throw new IllegalArgumentException("Invalid sender phone number format.");
        }
        if (smsDto.getRecipientNumber() == null || smsDto.getRecipientNumber().trim().isEmpty()) {
            throw new IllegalArgumentException("Recipient phone number is required.");
        }
        if (!smsDto.getRecipientNumber().matches("^\\+?[0-9]{10,15}$")) {
            throw new IllegalArgumentException("Invalid recipient phone number format.");
        }
    }

    private String sanitize(String input) {
        if (input == null)
            return null;
        // Basic sanitization: strip HTML tags if any (though rare in SMS)
        // and handle any problematic characters if necessary.
        return input.replaceAll("<[^>]*>", "");
    }
}
