package com.antigravity.expensetracker.config;

import com.antigravity.expensetracker.model.Bill;
import com.antigravity.expensetracker.model.Expense;
import com.antigravity.expensetracker.model.User;
import com.antigravity.expensetracker.repository.BillRepository;
import com.antigravity.expensetracker.repository.ExpenseRepository;
import com.antigravity.expensetracker.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Configuration
public class DataSeeder {

    @Bean
    CommandLineRunner initDatabase(UserRepository userRepository,
            ExpenseRepository expenseRepository,
            BillRepository billRepository) {
        return args -> {
            if (userRepository.count() == 0) {
                User user = new User();
                user.setEmail("alex@example.com");
                user.setFirstName("Alex");
                user.setLastName("Doe");
                user.setMobileNumber("9876543210");
                user.setPassword("password");
                user.setMonthlyBudget(50000.0);
                user.setCurrency("INR");
                user = userRepository.save(user);

                // Expenses
                Expense e1 = new Expense();
                e1.setAmount(new BigDecimal("450.00"));
                e1.setCategory("Food");
                e1.setMerchant("Starbucks");
                e1.setDate(LocalDateTime.now());
                e1.setSource("SMS");
                e1.setType("Purchase");
                e1.setNotes("Coffee break");
                e1.setUser(user);
                expenseRepository.save(e1);

                Expense e2 = new Expense();
                e2.setAmount(new BigDecimal("850.00"));
                e2.setCategory("Transport");
                e2.setMerchant("Uber");
                e2.setDate(LocalDateTime.now().minusDays(1));
                e2.setSource("Mail");
                e2.setType("Purchase");
                e2.setUser(user);
                expenseRepository.save(e2);

                Expense e3 = new Expense();
                e3.setAmount(new BigDecimal("2500.00"));
                e3.setCategory("Utilities");
                e3.setMerchant("Electric Company");
                e3.setDate(LocalDateTime.now().minusDays(2));
                e3.setSource("Mail");
                e3.setType("BillPayment");
                e3.setUser(user);
                expenseRepository.save(e3);

                // Bills
                Bill b1 = new Bill();
                b1.setTitle("Internet Bill");
                b1.setAmount(new BigDecimal("999.00"));
                b1.setDueDate(LocalDateTime.now().plusDays(3));
                b1.setUser(user);
                billRepository.save(b1);

                Bill b2 = new Bill();
                b2.setTitle("Netflix Subscription");
                b2.setAmount(new BigDecimal("649.00"));
                b2.setDueDate(LocalDateTime.now().plusDays(7));
                b2.setUser(user);
                billRepository.save(b2);

                System.out.println("Database initialized using DataSeeder");
            }
        };
    }
}
