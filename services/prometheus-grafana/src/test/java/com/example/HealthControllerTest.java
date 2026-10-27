package com.example;

import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;

class HealthControllerTest {
    @Test
    void healthReportsOk() {
        assertEquals("ok", new HealthController().health().get("status"));
    }
}
