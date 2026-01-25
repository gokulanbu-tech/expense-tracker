package com.antigravity.expensetracker.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class SmsDto {
    private String messageId;
    private String content;
    private String senderNumber;
    private String recipientNumber;
    private LocalDateTime timestamp;
    private String attachmentInfo;
    private String encryptionStatus;
}
