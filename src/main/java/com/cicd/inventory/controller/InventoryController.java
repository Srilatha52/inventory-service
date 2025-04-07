package com.cicd.inventory.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/inventory")
public class InventoryController {
    @GetMapping
    public String getInventoryStatus() {
        return "Inventory microservice is running! ✅";
    }
}