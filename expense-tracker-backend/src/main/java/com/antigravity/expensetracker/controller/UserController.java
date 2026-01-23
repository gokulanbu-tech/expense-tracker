package com.antigravity.expensetracker.controller;

import com.antigravity.expensetracker.model.User;
import com.antigravity.expensetracker.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/user")
@CrossOrigin(origins = "http://localhost:5173")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @GetMapping
    public User getUser() {
        // For simplicity in this demo, return the first user or create a default one
        return userRepository.findAll().stream().findFirst().orElseGet(() -> {
            User newUser = new User();
            newUser.setEmail("user@example.com");
            newUser.setFirstName("Demo");
            newUser.setLastName("User");
            newUser.setMobileNumber("1234567890");
            newUser.setPassword("password");
            return userRepository.save(newUser);
        });
    }

    @PutMapping
    public User updateUser(@RequestBody User user) {
        return userRepository.save(user);
    }
}
