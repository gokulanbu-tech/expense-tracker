package com.antigravity.expensetracker.service;

import com.antigravity.expensetracker.dto.EmailDto;
import com.antigravity.expensetracker.model.SmsMessage;
import com.antigravity.expensetracker.model.User;
import com.antigravity.expensetracker.repository.SmsMessageRepository;
import com.antigravity.expensetracker.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class EmailService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SmsMessageRepository smsMessageRepository;

    public SmsMessage processEmail(EmailDto emailDto) {
        // 1. Identify User
        // We look for the user whose email matches the 'from' address (if it's a direct
        // forward)
        // or we check if the 'to' address contains a specific marker.
        // For simplicity, we'll search by the sender's email.
        Optional<User> userOptional = userRepository.findByEmail(emailDto.getFrom());

        if (userOptional.isEmpty()) {
            throw new RuntimeException("Unauthorized: No registered user found for email " + emailDto.getFrom());
        }

        // 2. Extract Data (Simple regex for Bank Emails)
        // We'll look for amounts like ₹500, Rs. 500, Rs 500
        String amount = extractAmount(emailDto.getBody());
        String merchant = extractMerchant(emailDto.getSubject(), emailDto.getBody());

        // 3. Store as a 'SmsMessage' (Generalizing it as a Bank Notification)
        SmsMessage emailNotification = new SmsMessage();
        emailNotification.setMessageId("EMAIL_" + UUID.randomUUID().toString());
        emailNotification.setContent("[Parsed: ₹" + amount + " at " + merchant + "] " + emailDto.getBody());
        emailNotification.setSenderNumber(emailDto.getFrom()); // Using email as sender
        emailNotification.setRecipientNumber(emailDto.getTo());
        emailNotification.setDeviceTimestamp(LocalDateTime.now());
        emailNotification.setDeliveryStatus("EMAIL_SYNCED");
        emailNotification.setCreatedAt(LocalDateTime.now());

        return smsMessageRepository.save(emailNotification);
    }

    private String extractAmount(String content) {
        Pattern pattern = Pattern.compile("(?:Rs|₹|INR)\\.?\\s?([\\d,]+\\.?\\d{0,2})", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(content);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return "0.0";
    }

    private String extractMerchant(String subject, String body) {
        // Placeholder for more complex merchant extraction logic
        // For now, return a snippet or a label
        return "Bank Alert: " + (subject.length() > 30 ? subject.substring(0, 30) : subject);
    }
}
