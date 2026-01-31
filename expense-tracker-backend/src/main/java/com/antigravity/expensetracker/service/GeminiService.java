package com.antigravity.expensetracker.service;

import com.antigravity.expensetracker.dto.EmailParseRequest;
import com.antigravity.expensetracker.dto.ExpenseExtractionResponse;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.util.retry.Retry;

import java.math.BigDecimal;
import java.time.Duration;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class GeminiService {

    private final WebClient webClient;
    private final ObjectMapper objectMapper;

    @Value("${openai.api.key}")
    private String apiKey;

    private static final String OPENAI_URL = "https://api.openai.com/v1/chat/completions";
    private static final String MODEL = "gpt-4o-mini";

    public GeminiService(WebClient.Builder webClientBuilder, ObjectMapper objectMapper) {
        this.webClient = webClientBuilder.build();
        this.objectMapper = objectMapper;
    }

    public ExpenseExtractionResponse parseEmail(EmailParseRequest request) {
        if (request.getBody() == null || request.getBody().trim().isEmpty()) {
            throw new IllegalArgumentException("Email body cannot be empty");
        }

        String prompt = createPrompt(request);

        try {
            String jsonResponse = callOpenAiApi(prompt);
            return parseOpenAiResponse(jsonResponse);
        } catch (Exception e) {
            log.error("Failed to parse email with OpenAI", e);
            ExpenseExtractionResponse errorResponse = new ExpenseExtractionResponse();
            errorResponse.setError(true);
            return errorResponse;
        }
    }

    private String createPrompt(EmailParseRequest request) {
        return String.format(
                "Analyze the following transaction email and extract structured data. " +
                        "Return ONLY a clean JSON object (no markdown formatting) with these fields: " +
                        "amount (numeric, no symbols), " +
                        "currency (ISO code, e.g. INR, USD), " +
                        "merchant (string, beneficiary name OR merchant name), " +
                        "date (YYYY-MM-DD), " +
                        "category (string, default to 'Transaction' for money transfers), " +
                        "type (string, use 'Credited' for income/deposits, 'Debited' for expense/spends), " +
                        "paymentMethod (string), " +
                        "notes (string, extract the full transaction reference/narration e.g. 'UPI/P2A/...'), " +
                        "confidence (0.0 to 1.0). " +
                        "If a field is missing, use null. " +
                        "\n\nContext:\nSender: %s\nSubject: %s\nBody: %s",
                request.getSender(), request.getSubject(), request.getBody());
    }

    private void logToFile(String message) {
        try (java.io.FileWriter fw = new java.io.FileWriter("debug_parse.log", true);
                java.io.PrintWriter pw = new java.io.PrintWriter(fw)) {
            pw.println(java.time.LocalDateTime.now() + ": " + message);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String callOpenAiApi(String prompt) {
        logToFile("Calling OpenAI API...");
        Map<String, Object> requestBody = Map.of(
                "model", MODEL,
                "messages", List.of(
                        Map.of("role", "system", "content",
                                "You are a helpful financial assistant. You extract structured data from emails."),
                        Map.of("role", "user", "content", prompt)),
                "temperature", 0.1);

        try {
            String response = webClient.post()
                    .uri(OPENAI_URL)
                    .header("Authorization", "Bearer " + apiKey)
                    .header("Content-Type", "application/json")
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(String.class)
                    .timeout(Duration.ofSeconds(60)) // Increased timeout
                    .retryWhen(Retry.backoff(3, Duration.ofSeconds(2)))
                    .block();
            logToFile("OpenAI Response: " + response);
            return response;
        } catch (Exception e) {
            logToFile("OpenAI FAILURE: " + e.getMessage());
            throw e;
        }
    }

    private ExpenseExtractionResponse parseOpenAiResponse(String rawResponse) {
        ExpenseExtractionResponse response = new ExpenseExtractionResponse();
        try {
            JsonNode root = objectMapper.readTree(rawResponse);
            JsonNode choices = root.path("choices");
            if (choices.isArray() && !choices.isEmpty()) {
                JsonNode contentNode = choices.get(0).path("message").path("content");
                String text = contentNode.asText();

                // Clean up any potential markdown code blocks
                if (text.startsWith("```json")) {
                    text = text.replace("```json", "").replace("```", "");
                } else if (text.startsWith("```")) {
                    text = text.replace("```", "");
                }

                JsonNode data = objectMapper.readTree(text);

                if (data.has("amount") && !data.get("amount").isNull()) {
                    response.setAmount(new BigDecimal(data.get("amount").asText()));
                }
                if (data.has("currency"))
                    response.setCurrency(data.get("currency").asText(null));
                if (data.has("merchant"))
                    response.setMerchant(data.get("merchant").asText(null));
                if (data.has("date"))
                    response.setDate(data.get("date").asText(null));
                if (data.has("category"))
                    response.setCategory(data.get("category").asText(null));
                if (data.has("type"))
                    response.setType(data.get("type").asText(null));
                if (data.has("paymentMethod"))
                    response.setPaymentMethod(data.get("paymentMethod").asText(null));
                if (data.has("notes"))
                    response.setNotes(data.get("notes").asText(null));
                if (data.has("confidence"))
                    response.setConfidence(data.get("confidence").asDouble());

                response.setError(false);
            } else {
                log.warn("OpenAI response contained no choices");
                response.setError(true);
            }
        } catch (Exception e) {
            log.error("Error parsing OpenAI JSON response", e);
            response.setError(true);
        }
        return response;
    }
}
