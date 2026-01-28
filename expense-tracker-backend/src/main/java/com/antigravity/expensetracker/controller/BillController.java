package com.antigravity.expensetracker.controller;

import com.antigravity.expensetracker.model.Bill;
import com.antigravity.expensetracker.service.BillService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/bills")
@CrossOrigin(origins = "http://localhost:5173") // Adjust allowed origins as needed
public class BillController {

    @Autowired
    private BillService billService;

    @GetMapping
    public List<Bill> getAllBills(@RequestParam(required = false) UUID userId) {
        return billService.getAllBills(userId);
    }

    @PostMapping
    public Bill createBill(@RequestBody Bill bill) {
        return billService.createBill(bill);
    }

    @PutMapping("/{id}/pay")
    public Bill markAsPaid(@PathVariable UUID id) {
        return billService.markAsPaid(id);
    }

    @DeleteMapping("/{id}")
    public void deleteBill(@PathVariable UUID id) {
        billService.deleteBill(id);
    }

    @PutMapping("/{id}")
    public Bill updateBill(@PathVariable UUID id, @RequestBody Bill bill) {
        return billService.updateBill(id, bill);
    }
}
