package com.antigravity.expensetracker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@org.springframework.cache.annotation.EnableCaching
public class ExpenseTrackerBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(ExpenseTrackerBackendApplication.class, args);
	}

}
