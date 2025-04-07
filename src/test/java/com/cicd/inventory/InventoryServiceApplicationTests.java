package com.cicd.inventory;

import com.cicd.inventory.controller.InventoryController;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class InventoryServiceApplicationTests {
	@Autowired
	private InventoryController controller;

	@Autowired
	private ApplicationContext context;

	@LocalServerPort
	private int port;

	@Autowired
	private TestRestTemplate restTemplate;

	@Test
	void contextLoads() {
		assertNotNull(context, "Application context should load successfully");
	}

	@Test
	void testInventoryStatus() {
		assertEquals("Inventory microservice is running! ✅", controller.getInventoryStatus());
	}

	@Test
	void testMainMethod() throws InterruptedException {
		// Run main() in a separate thread to avoid blocking the test
		String[] args = new String[] {};
		Thread appThread = new Thread(() -> InventoryServiceApplication.main(args));
		appThread.start();

		// Wait briefly for the application to start
		Thread.sleep(2000); // Adjust as needed based on startup time

		// Verify the application is running by hitting the endpoint
		String response = restTemplate.getForObject("http://localhost:" + port + "/api/inventory", String.class);
		assertEquals("Inventory microservice is running! ✅", response);

		// Clean up: Stop the application (optional, for test isolation)
		appThread.interrupt();
	}
}