package com.elsys.server.base;

import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * Base for pure unit tests — no Spring context, Mockito only.
 * Fast. Use for service/utility logic that has no framework dependencies.
 *
 * Usage:
 *   class MyServiceTest extends BaseUnitTest {
 *       @Mock MyRepository repo;
 *       @InjectMocks MyService service;
 *   }
 */
@ExtendWith(MockitoExtension.class)
public abstract class BaseUnitTest {
}
