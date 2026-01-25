package com.antigravity.expensetracker.controller;

import com.antigravity.expensetracker.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
@CrossOrigin(origins = "http://localhost:5173")
public class UserController {

    @Autowired
    private com.antigravity.expensetracker.repository.UserRepository userRepository;

    @Autowired
    private com.antigravity.expensetracker.service.UserService userService;

    @GetMapping("/{id}")
    public User getUser(@PathVariable("id") java.util.UUID id) {
        System.out.println("Fetching user with ID: " + id);
        return userRepository.findById(id).orElseThrow(() -> new RuntimeException("User not found"));
    }

    @PutMapping("/{id}")
    public User updateUser(@PathVariable("id") java.util.UUID id, @RequestBody User user) {
        System.out.println("Updating user with ID: " + id);
        return userService.updateUser(id, user);
    }
}
