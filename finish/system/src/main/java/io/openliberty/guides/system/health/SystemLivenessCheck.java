// tag::copyright[]
/*******************************************************************************
 * Copyright (c) 2022, 2024 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 *******************************************************************************/
// end::copyright[]
package io.openliberty.guides.system.health;

import io.openliberty.guides.system.SystemResource;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;

import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.health.Liveness;
import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;

@Liveness
@ApplicationScoped
public class SystemLivenessCheck implements HealthCheck {

    @Override
    public HealthCheckResponse call() {
        MemoryMXBean memBean = ManagementFactory.getMemoryMXBean();
        long memUsed = memBean.getHeapMemoryUsage().getUsed();
        long memMax = memBean.getHeapMemoryUsage().getMax();
        return HealthCheckResponse.named(SystemResource.class
                                             .getSimpleName() + " Liveness Check")
                                             .status(memUsed < memMax * 0.9).build();
    }
}
