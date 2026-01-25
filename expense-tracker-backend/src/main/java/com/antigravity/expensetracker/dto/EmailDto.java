package com.antigravity.expensetracker.dto;

import lombok.Data;

@Data
public class EmailDto {
    private String from;
    private String to;
    private String subject;
    private String body;
    private String timestamp;
}
