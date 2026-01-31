package com.antigravity.expensetracker.dto;

import lombok.Data;

@Data
public class EmailParseRequest {
    private String subject;
    private String body;
    private String sender;
}
