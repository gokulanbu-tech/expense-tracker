package com.antigravity.expensetracker.controller;

import com.antigravity.expensetracker.model.Bill;
import com.antigravity.expensetracker.repository.BillRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/bills")
@CrossOrigin(origins = "http://localhost:5173")
public class BillController {

    @Autowired
    private BillRepository billRepository;

    @GetMapping
    public List<Bill> getAllBills(@RequestParam(required = false) UUID userId) {
        if (userId != null) {
            return billRepository.findByUserId(userId);
        }
        return billRepository.findAll();
    }

    @PostMapping
    public Bill createBill(@RequestBody Bill bill) {
        return billRepository.save(bill);
    }

    @PutMapping("/{id}/pay")
    public Bill markAsPaid(@PathVariable UUID id) {
        return billRepository.findById(id).map(bill -> {
            bill.setIsPaid(true);
            return billRepository.save(bill);
        }).orElseThrow(() -> new RuntimeException("Bill not found"));
    }
}
