package com.antigravity.expensetracker.service;

import com.antigravity.expensetracker.model.User;
import com.antigravity.expensetracker.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public User registerUser(User user) {
        if (userRepository.findByMobileNumber(user.getMobileNumber()).isPresent()) {
            throw new RuntimeException("User with this mobile number already exists");
        }
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            throw new RuntimeException("User with this email already exists");
        }
        return userRepository.save(user);
    }

    public User loginUser(String mobileNumber, String password) {
        Optional<User> userOpt = userRepository.findByMobileNumber(mobileNumber);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (user.getPassword().equals(password)) {
                return user;
            }
        }
        throw new RuntimeException("Invalid credentials");
    }

    public User findOrCreateByEmail(String email, String firstName, String lastName) {
        return userRepository.findByEmail(email).orElseGet(() -> {
            User newUser = new User();
            newUser.setEmail(email);
            newUser.setFirstName(firstName);
            newUser.setLastName(lastName);
            newUser.setMobileNumber("G-" + System.currentTimeMillis()); // Placeholder for Google login
            newUser.setPassword("google-auth-pwd"); // Dummy password
            return userRepository.save(newUser);
        });
    }

    public User updateUser(java.util.UUID id, User userDetails) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!user.getEmail().equalsIgnoreCase(userDetails.getEmail())) {
            if (userRepository.findByEmail(userDetails.getEmail()).isPresent()) {
                throw new RuntimeException("User with this email already exists");
            }
            user.setEmail(userDetails.getEmail());
        }

        user.setFirstName(userDetails.getFirstName());
        user.setLastName(userDetails.getLastName());
        user.setMonthlyBudget(userDetails.getMonthlyBudget());

        return userRepository.save(user);
    }
}
