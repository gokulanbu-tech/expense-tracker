package com.antigravity.expensetracker.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Suggestion {
    private String id;
    private String title;
    private String description;
    private String category;
    private Double potentialSavings;
    private String type; // 'habit', 'subscription', 'one-time'
    private String merchant;
}
